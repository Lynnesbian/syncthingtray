#ifndef WEBVIEW_DIALOG_H
#define WEBVIEW_DIALOG_H
#ifndef SYNCTHINGWIDGETS_NO_WEBVIEW

#include "./webviewdefs.h"

#include "../settings/settings.h"

#include <QMainWindow>

QT_FORWARD_DECLARE_CLASS(WEB_VIEW_PROVIDER)
QT_FORWARD_DECLARE_CLASS(QWebEngineProfile)

namespace Settings {
struct ConnectionSettings;
}

namespace QtGui {

class SYNCTHINGWIDGETS_EXPORT WebViewDialog : public QMainWindow {
    Q_OBJECT
public:
    WebViewDialog(QWidget *parent = nullptr);
    ~WebViewDialog();

public slots:
    void applySettings(const Data::SyncthingConnectionSettings &connectionSettings);
    const Data::SyncthingConnectionSettings &settings() const;
#if defined(SYNCTHINGWIDGETS_USE_WEBKIT)
    bool isModalVisible() const;
#endif
    void closeUnlessModalVisible();

protected:
    void closeEvent(QCloseEvent *event);
    void keyPressEvent(QKeyEvent *event);
#if defined(SYNCTHINGWIDGETS_USE_WEBENGINE)
    bool eventFilter(QObject *watched, QEvent *event);
#endif

private:
    SYNCTHINGWIDGETS_WEB_VIEW *m_view;
    Data::SyncthingConnectionSettings m_settings;
#if defined(SYNCTHINGWIDGETS_USE_WEBENGINE)
    QWebEngineProfile *m_profile;
#endif
};

inline const Data::SyncthingConnectionSettings &WebViewDialog::settings() const
{
    return m_settings;
}

} // namespace QtGui

#endif // SYNCTHINGWIDGETS_NO_WEBVIEW
#endif // WEBVIEW_DIALOG_H
