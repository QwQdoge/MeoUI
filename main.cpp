#include <QGuiApplication>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QIODevice>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QRegularExpression>
#include <QResource>
#include <QQuickWindow>
#include <QTimer>
#include <QObject>
#include <QTextStream>
#include <QUrl>
#include <QWindow>
#include <Qt>

namespace {
QFile *gLogFile = nullptr;

#ifndef MEOUI_DEFAULT_OUTPUT_ROOT
#define MEOUI_DEFAULT_OUTPUT_ROOT ""
#endif

QString optionValue(const QStringList &arguments, const QString &option) {
  const QString prefix = option + QLatin1Char('=');
  for (qsizetype index = 1; index < arguments.size(); ++index) {
    const QString &argument = arguments.at(index);
    if (argument.startsWith(prefix)) {
      return argument.mid(prefix.size()).trimmed();
    }
    if (argument == option && index + 1 < arguments.size()) {
      return arguments.at(index + 1).trimmed();
    }
  }
  return {};
}

QString absolutePath(const QString &path, const QString &baseDirectory) {
  if (path.isEmpty()) {
    return {};
  }
  const QFileInfo fileInfo(path);
  return QDir::cleanPath(fileInfo.isAbsolute()
                             ? fileInfo.absoluteFilePath()
                             : QDir(baseDirectory).absoluteFilePath(path));
}

QString defaultRunId() {
  return QDateTime::currentDateTimeUtc().toString(
             QStringLiteral("yyyy-MM-ddTHHmmss'Z'")) +
         QStringLiteral("-showcase-run");
}

bool isValidRunId(const QString &runId) {
  static const QRegularExpression pattern(
      QStringLiteral("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}Z-"
                     "[A-Za-z0-9][A-Za-z0-9._-]*$"));
  return pattern.match(runId).hasMatch();
}

QString validationRunId(const QStringList &arguments) {
  const QString commandLineRunId = optionValue(arguments, QStringLiteral("--run-id"));
  if (!commandLineRunId.isEmpty()) {
    return commandLineRunId;
  }

  const QString environmentRunId = qEnvironmentVariable("MEOUI_RUN_ID").trimmed();
  return environmentRunId.isEmpty() ? defaultRunId() : environmentRunId;
}

QString outputRoot(const QStringList &arguments) {
  const QString commandLineRoot = optionValue(arguments, QStringLiteral("--output-root"));
  if (!commandLineRoot.isEmpty()) {
    return absolutePath(commandLineRoot, QDir::currentPath());
  }

  const QString environmentRoot = qEnvironmentVariable("MEO_OUTPUT_ROOT").trimmed();
  if (!environmentRoot.isEmpty()) {
    return absolutePath(environmentRoot, QDir::currentPath());
  }

  const QString configuredRoot = QString::fromUtf8(MEOUI_DEFAULT_OUTPUT_ROOT);
  if (!configuredRoot.isEmpty()) {
    return absolutePath(configuredRoot, QDir::currentPath());
  }

  // CMake always supplies MEOUI_DEFAULT_OUTPUT_ROOT for supported builds.
  // This final fallback keeps an independently compiled binary functional
  // without silently placing logs next to the executable.
  return QDir::current().absoluteFilePath(QStringLiteral("outputs"));
}

QString validationDirectory(const QStringList &arguments,
                            const QString &runId) {
  QString explicitDirectory =
      optionValue(arguments, QStringLiteral("--validation-dir"));
  if (explicitDirectory.isEmpty()) {
    explicitDirectory = optionValue(arguments, QStringLiteral("--output-dir"));
  }
  if (!explicitDirectory.isEmpty()) {
    return absolutePath(explicitDirectory, QDir::currentPath());
  }

  const QString environmentDirectory =
      qEnvironmentVariable("MEOUI_VALIDATION_DIR").trimmed();
  if (!environmentDirectory.isEmpty()) {
    return absolutePath(environmentDirectory, QDir::currentPath());
  }

  return QDir(outputRoot(arguments))
      .filePath(QStringLiteral("meo-ui/validation/") + runId);
}

bool hasExplicitRunId(const QStringList &arguments) {
  return !optionValue(arguments, QStringLiteral("--run-id")).isEmpty() ||
         !qEnvironmentVariable("MEOUI_RUN_ID").trimmed().isEmpty();
}

bool hasExplicitValidationDirectory(const QStringList &arguments) {
  return !optionValue(arguments, QStringLiteral("--validation-dir")).isEmpty() ||
         !optionValue(arguments, QStringLiteral("--output-dir")).isEmpty() ||
         !qEnvironmentVariable("MEOUI_VALIDATION_DIR").trimmed().isEmpty();
}

QString uniqueDefaultRunId(const QStringList &arguments, const QString &runId) {
  if (hasExplicitRunId(arguments) || hasExplicitValidationDirectory(arguments)) {
    return runId;
  }

  const QString initialRunId = runId;
  QString candidateRunId = initialRunId;
  int suffix = 2;
  while (QFileInfo::exists(validationDirectory(arguments, candidateRunId))) {
    candidateRunId = initialRunId + QLatin1Char('-') + QString::number(suffix);
    ++suffix;
  }
  return candidateRunId;
}

bool initializeValidationDirectory(const QString &directory,
                                   const QString &runId) {
  if (!QDir().mkpath(directory)) {
    return false;
  }

  const QString readmePath = QDir(directory).filePath(QStringLiteral("README.md"));
  if (!QFileInfo::exists(readmePath)) {
    QFile readme(readmePath);
    if (!readme.open(QIODevice::WriteOnly | QIODevice::Text)) {
      return false;
    }

    QTextStream out(&readme);
    out << "# MeoUI Showcase validation run\n\n"
        << "- Run ID: `" << runId << "`\n"
        << "- Generated by: `MeoShowcaseDemo`\n"
        << "- Runtime log: `MeoShowcaseDemo.log`\n"
        << "- Optional screenshot: pass `--screenshot=<path>`; a relative path "
           "is stored in this run directory.\n\n"
        << "This directory contains one reviewable Showcase run. Build and "
           "coverage logs are written here by the repository launch scripts.\n";
  }

  const QString checklistPath =
      QDir(directory).filePath(QStringLiteral("delivery-checklist.md"));
  if (QFileInfo::exists(checklistPath)) {
    return true;
  }

  QFile checklist(checklistPath);
  if (!checklist.open(QIODevice::WriteOnly | QIODevice::Text)) {
    return false;
  }
  QTextStream checklistOut(&checklist);
  checklistOut
      << "# MeoUI Showcase delivery checklist\n\n"
      << "Status: complete this checklist before claiming delivery acceptance.\n\n"
      << "- Public QML exports: see `coverage.log` for the automated "
         "qmldir-to-sample gate.\n"
      << "- Changed tokens and theme behavior:\n"
      << "- Changed C++ runtime/API surface:\n"
      << "- Changed assets or packaging:\n"
      << "- Changed visible behavior and its Showcase sample:\n"
      << "- Visual/manual review scope and result:\n"
      << "- Intentional non-visual items and rationale:\n";
  return true;
}

void messageHandler(QtMsgType type, const QMessageLogContext &context,
                    const QString &message) {
  const char *level = "debug";
  switch (type) {
  case QtInfoMsg:
    level = "info";
    break;
  case QtWarningMsg:
    level = "warning";
    break;
  case QtCriticalMsg:
    level = "critical";
    break;
  case QtFatalMsg:
    level = "fatal";
    break;
  case QtDebugMsg:
    break;
  }

  if (gLogFile && gLogFile->isOpen()) {
    QTextStream out(gLogFile);
    out << QDateTime::currentDateTime().toString(Qt::ISODate) << " [" << level
        << "] " << message;
    if (context.file) {
      out << " (" << context.file << ":" << context.line << ")";
    }
    out << '\n';
    out.flush();
  }

  if (type == QtFatalMsg) {
    abort();
  }
}
} // namespace

int main(int argc, char *argv[]) {
  // 启用高分屏缩放支持 (Qt6 默认开启，但加上以防万一)
  QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
      Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
  QQuickStyle::setStyle(QStringLiteral("Basic"));
  QGuiApplication app(argc, argv);

  QString runId = validationRunId(app.arguments());
  if (!isValidRunId(runId)) {
    qCritical() << "Invalid Showcase run ID" << runId
                << "; expected YYYY-MM-DDTHHMMSSZ-short-label.";
    return 2;
  }
  runId = uniqueDefaultRunId(app.arguments(), runId);
  const QString validationDir = validationDirectory(app.arguments(), runId);
  if (!initializeValidationDirectory(validationDir, runId)) {
    qCritical() << "Could not create Showcase validation directory"
                << validationDir;
    return 2;
  }

  QFile logFile(
      QDir(validationDir).filePath(QStringLiteral("MeoShowcaseDemo.log")));
  if (!logFile.open(QIODevice::WriteOnly | QIODevice::Text |
                    QIODevice::Truncate)) {
    qCritical() << "Could not open Showcase runtime log" << logFile.fileName();
    return 2;
  }
  gLogFile = &logFile;
  qInstallMessageHandler(messageHandler);

  qInfo() << "Starting MeoShowcaseDemo from" << app.applicationDirPath();
  qInfo() << "Showcase validation run" << runId << "writes to"
          << validationDir;

  // The MeoUI module lives in a linked library, so register its embedded QML
  // resources before resolving the application's QML entry point.
  Q_INIT_RESOURCE(qmake_MeoUI);
  Q_INIT_RESOURCE(meoui_module_raw_qml_0);

  QQmlApplicationEngine engine;

  // 让 QML 引擎能够找到 MeoUI 模块
  engine.addImportPath(app.applicationDirPath() + "/MeoUI");
  engine.addImportPath(app.applicationDirPath());
  engine.addImportPath(app.applicationDirPath() + "/qml");

  const QList<QUrl> entryPoints = {
      QUrl(QStringLiteral("qrc:/qt/qml/MeoUI/showcase/MeoShowcase.qml")),
      QUrl::fromLocalFile(QDir(app.applicationDirPath())
                              .filePath("MeoUI/showcase/MeoShowcase.qml"))};

  for (const QUrl &url : entryPoints) {
    qInfo() << "Loading QML entry point" << url;
    engine.load(url);
    if (!engine.rootObjects().isEmpty()) {
      qInfo() << "Loaded QML root from" << url;
      break;
    }
    qWarning() << "No root object was created from" << url;
  }

  if (engine.rootObjects().isEmpty()) {
    qCritical() << "MeoShowcaseDemo could not create a QML root object.";
    return -1;
  }

  QObject *root = engine.rootObjects().constFirst();
  qInfo() << "Root object class:" << root->metaObject()->className();
  if (auto *window = qobject_cast<QWindow *>(root)) {
    qInfo() << "Root window visible:" << window->isVisible() << "size:"
            << window->size();
    if (!window->isVisible()) {
      window->show();
      qInfo() << "Root window was hidden; show() was called.";
    }
    window->raise();
    window->requestActivate();

    QString screenshotPath;
    for (const QString &argument : app.arguments()) {
      if (argument.startsWith(QStringLiteral("--screenshot="))) {
        screenshotPath = argument.mid(13);
        break;
      }
    }
    if (!screenshotPath.isEmpty()) {
      screenshotPath = absolutePath(screenshotPath, validationDir);
      if (!QDir().mkpath(QFileInfo(screenshotPath).absolutePath())) {
        qCritical() << "Could not create screenshot directory for"
                    << screenshotPath;
        return 2;
      }
      if (auto *quickWindow = qobject_cast<QQuickWindow *>(window)) {
        QTimer::singleShot(1200, quickWindow,
                           [quickWindow, screenshotPath, &app]() {
          const QImage image = quickWindow->grabWindow();
          if (!image.isNull() && image.save(screenshotPath)) {
            qInfo() << "Saved visual regression image to" << screenshotPath;
            app.quit();
            return;
          }
          qCritical() << "Could not save visual regression image to"
                      << screenshotPath;
          app.exit(2);
        });
        QTimer::singleShot(10000, &app, [&app]() { app.exit(3); });
      }
    }
  } else {
    qWarning() << "QML root object is not a QWindow.";
  }

  const int exitCode = app.exec();
  qInfo() << "MeoShowcaseDemo exited with code" << exitCode;
  return exitCode;
}
