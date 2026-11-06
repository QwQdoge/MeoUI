#include "meoinputmodality.h"

#include <QtCore/QCoreApplication>
#include <QtCore/QEvent>
#include <QtGui/QKeyEvent>
#include <QtGui/QPointerEvent>
#include <QtGui/QPointingDevice>

MeoInputModality::MeoInputModality(QObject *parent)
    : QObject(parent)
{
    if (QCoreApplication *app = QCoreApplication::instance())
        app->installEventFilter(this);
}

MeoInputModality::~MeoInputModality()
{
    if (QCoreApplication *app = QCoreApplication::instance())
        app->removeEventFilter(this);
}

void MeoInputModality::setKeyboardModality(bool keyboard)
{
    update(keyboard, m_pointerType);
}

void MeoInputModality::update(bool keyboard, const QString &pointerType)
{
    if (m_keyboard == keyboard && m_pointerType == pointerType)
        return;
    m_keyboard = keyboard;
    m_pointerType = pointerType;
    Q_EMIT modalityChanged();
}

static bool isModifierKey(int key)
{
    switch (key) {
    case Qt::Key_Shift:
    case Qt::Key_Control:
    case Qt::Key_Meta:
    case Qt::Key_Alt:
    case Qt::Key_AltGr:
    case Qt::Key_CapsLock:
    case Qt::Key_NumLock:
    case Qt::Key_Super_L:
    case Qt::Key_Super_R:
    case Qt::Key_Hyper_L:
    case Qt::Key_Hyper_R:
        return true;
    default:
        return false;
    }
}

bool MeoInputModality::eventFilter(QObject *watched, QEvent *event)
{
    // Window-level events reach the filter once per object in the delivery
    // chain; only the cheap type check runs for everything else.
    switch (event->type()) {
    case QEvent::KeyPress: {
        const auto *key = static_cast<QKeyEvent *>(event);
        // Modifier-only presses (e.g. Ctrl held for Ctrl+click) are not
        // keyboard navigation.
        if (!isModifierKey(key->key()))
            update(true, m_pointerType);
        break;
    }
    case QEvent::MouseButtonPress:
    case QEvent::MouseButtonDblClick:
    case QEvent::TouchBegin:
    case QEvent::TabletPress: {
        const auto *pointer = static_cast<QPointerEvent *>(event);
        QString type = QStringLiteral("mouse");
        if (const QPointingDevice *device = pointer->pointingDevice()) {
            switch (device->type()) {
            case QInputDevice::DeviceType::TouchScreen:
                type = QStringLiteral("touch");
                break;
            case QInputDevice::DeviceType::Stylus:
            case QInputDevice::DeviceType::Airbrush:
            case QInputDevice::DeviceType::Puck:
                type = QStringLiteral("pen");
                break;
            default:
                break;
            }
        }
        update(false, type);
        break;
    }
    default:
        break;
    }
    return QObject::eventFilter(watched, event);
}
