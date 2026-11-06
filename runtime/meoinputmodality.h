#pragma once

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtQml/qqml.h>

// Application-wide input modality, the QML equivalent of CSS :focus-visible
// and WinUI's keyboard-vs-pointer focus visuals.
//
// A non-modifier key press switches to keyboard modality; a mouse, touch or
// pen press switches to pointer modality and records the device type. Focus
// indicators should render only while `keyboard` is true, so a mouse click
// that moves focus does not leave a focus ring behind, while Tab and arrow
// navigation always shows where focus is.
//
// The initial state is keyboard modality: before any pointer interaction,
// programmatically placed initial focus must stay visible.
class MeoInputModality : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MeoInputModality)
    QML_SINGLETON

    Q_PROPERTY(bool keyboard READ keyboard NOTIFY modalityChanged)
    Q_PROPERTY(QString pointerType READ pointerType NOTIFY modalityChanged)
    Q_PROPERTY(bool touch READ touch NOTIFY modalityChanged)

public:
    explicit MeoInputModality(QObject *parent = nullptr);
    ~MeoInputModality() override;

    bool keyboard() const { return m_keyboard; }
    // "mouse", "touch", "pen" or "" before the first pointer press.
    QString pointerType() const { return m_pointerType; }
    bool touch() const { return m_pointerType == QLatin1String("touch"); }

    // Test and host hook: force a modality without synthesizing input.
    Q_INVOKABLE void setKeyboardModality(bool keyboard);

Q_SIGNALS:
    void modalityChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    void update(bool keyboard, const QString &pointerType);

    bool m_keyboard = true;
    QString m_pointerType;
};
