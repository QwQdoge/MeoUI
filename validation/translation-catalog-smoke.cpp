#include <QCoreApplication>
#include <QTest>
#include <QTranslator>

#ifndef MEOUI_TRANSLATIONS_BUILD_DIR
#define MEOUI_TRANSLATIONS_BUILD_DIR ""
#endif

class TranslationCatalogSmoke final : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void translatesReviewedSharedControlStrings()
    {
        QTranslator translator;
        const QString directory = QString::fromUtf8(MEOUI_TRANSLATIONS_BUILD_DIR);
        QVERIFY2(translator.load(QStringLiteral("meoui_zh_CN"), directory),
                 qPrintable(QStringLiteral("Could not load MeoUI catalog from %1").arg(directory)));

        QVERIFY(QCoreApplication::installTranslator(&translator));
        QCOMPARE(QCoreApplication::translate("MeoAccountSwitcher", "Manage accounts"),
                 QStringLiteral("管理账号"));
        QCOMPARE(QCoreApplication::translate("MeoDateInput", "Invalid date"),
                 QStringLiteral("请输入有效日期"));
        QCOMPARE(QCoreApplication::translate("MeoMediaController", "Next"),
                 QStringLiteral("下一首"));
        QCOMPARE(QCoreApplication::translate("MeoSettingsSidebar", "Search settings"),
                 QStringLiteral("搜索设置"));
        QCOMPARE(QCoreApplication::translate("MeoSettingsSidebar", "No matching settings"),
                 QStringLiteral("未找到匹配的设置"));
        QCOMPARE(QCoreApplication::translate("MeoSearchBar", "Clear search"),
                 QStringLiteral("清除搜索"));
        QCOMPARE(QCoreApplication::translate("MeoStatusCenter", "%1 unread").arg(2),
                 QStringLiteral("2 条未读"));
        QCOMPARE(QCoreApplication::translate("MeoWidgetSheet", "Add widget"),
                 QStringLiteral("添加小组件"));
        QCOMPARE(QCoreApplication::translate("MeoShowcase", "MeoUI MD3 Expressive Showcase"),
                 QStringLiteral("MeoUI MD3 表达性展示"));
        QCOMPARE(QCoreApplication::translate("ShowcaseCategoryPage", "Live sample"),
                 QStringLiteral("实时示例"));
        QCOMPARE(QCoreApplication::translate("ThemePage", "Theme and corner radius"),
                 QStringLiteral("主题与圆角"));
        QCOMPARE(QCoreApplication::translate("ExpressivePage", "Shape morph progress"),
                 QStringLiteral("形状变换进度"));
        QCOMPARE(QCoreApplication::translate("ShowcaseCatalog", "Controls"),
                 QStringLiteral("控件"));
        QCOMPARE(QCoreApplication::translate("ShowcaseCatalog",
                                              "Five effective-pixel breakpoints and adaptive page metrics."),
                 QStringLiteral("五个有效像素断点和自适应页面度量。"));
        QCOMPARE(QCoreApplication::translate("ShowcaseCatalog",
                                              "M3 surface card with elevated, filled, outlined, selected, and interactive variants."),
                 QStringLiteral("支持悬浮、填充、描边、已选和可交互变体的 M3 表面卡片。"));
        QCOMPARE(QCoreApplication::translate("ShowcaseSampleDelegate", "Type"),
                 QStringLiteral("类型"));
        QCOMPARE(QCoreApplication::translate("ShowcaseSampleDelegate", "No messages"),
                 QStringLiteral("没有消息"));
        QCOMPARE(QCoreApplication::translate("ShowcaseSampleDelegate", "Bluetooth status is unavailable"),
                 QStringLiteral("蓝牙状态不可用"));
        QCOMPARE(QCoreApplication::translate("ShowcaseApiTable", "Variants"),
                 QStringLiteral("变体"));
        QCOMPARE(QCoreApplication::translate("ShowcaseApiTable", "States"),
                 QStringLiteral("状态"));
        QCOMPARE(QCoreApplication::translate("ShowcaseApiTable", "API"),
                 QStringLiteral("接口"));
        QCoreApplication::removeTranslator(&translator);
        QCOMPARE(QCoreApplication::translate("MeoSettingsSidebar", "Search settings"),
                 QStringLiteral("Search settings"));
    }
};

QTEST_GUILESS_MAIN(TranslationCatalogSmoke)

#include "translation-catalog-smoke.moc"
