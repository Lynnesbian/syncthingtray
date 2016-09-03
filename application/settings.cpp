#include "./settings.h"

#include <qtutilities/settingsdialog/qtsettings.h>

#include <QString>
#include <QByteArray>
#include <QApplication>
#include <QSettings>
#include <QFrame>

using namespace Media;

namespace Settings {

bool &firstLaunch()
{
    static bool v = false;
    return v;
}

// connection
QString &syncthingUrl()
{
    static QString v;
    return v;
}
bool &authEnabled()
{
    static bool v = false;
    return v;
}
QString &userName()
{
    static QString v;
    return v;
}
QString &password()
{
    static QString v;
    return v;
}
QByteArray &apiKey()
{
    static QByteArray v;
    return v;
}

// notifications
bool &notifyOnDisconnect()
{
    static bool v = true;
    return v;
}
bool &notifyOnInternalErrors()
{
    static bool v = true;
    return v;
}
bool &notifyOnSyncComplete()
{
    static bool v = true;
    return v;
}
bool &showSyncthingNotifications()
{
    static bool v = true;
    return v;
}

// appearance
bool &showTraffic()
{
    static bool v = true;
    return v;
}
QSize &trayMenuSize()
{
    static QSize v(350, 300);
    return v;
}
int &frameStyle()
{
    static int v = QFrame::StyledPanel | QFrame::Sunken;
    return v;
}

// autostart/launcher
bool &launchSynchting()
{
    static bool v = false;
    return v;
}
QString &syncthingPath()
{
#ifdef PLATFORM_WINDOWS
    static QString v(QStringLiteral("syncthing.exe"));
#else
    static QString v(QStringLiteral("syncthing"));
#endif
    return v;
}
QString &syncthingArgs()
{
    static QString v;
    return v;
}

// web view
#if defined(SYNCTHINGTRAY_USE_WEBENGINE) || defined(SYNCTHINGTRAY_USE_WEBKIT)
bool &webViewDisabled()
{
    static bool v = false;
    return v;
}
double &webViewZoomFactor()
{
    static double v = 1.0;
    return v;
}
QByteArray &webViewGeometry()
{
    static QByteArray v;
    return v;
}
bool &webViewKeepRunning()
{
    static bool v = true;
    return v;
}
#endif

// Qt settings
Dialogs::QtSettings &qtSettings()
{
    static Dialogs::QtSettings v;
    return v;
}

void restore()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope,  QApplication::organizationName(), QApplication::applicationName());

    settings.beginGroup(QStringLiteral("tray"));
    firstLaunch() = !settings.contains(QStringLiteral("syncthingUrl"));
    syncthingUrl() = settings.value(QStringLiteral("syncthingUrl"), QStringLiteral("http://localhost:8080/")).toString();
    authEnabled() = settings.value(QStringLiteral("authEnabled"), false).toBool();
    userName() = settings.value(QStringLiteral("userName")).toString();
    password() = settings.value(QStringLiteral("password")).toString();
    apiKey() = settings.value(QStringLiteral("apiKey")).toByteArray();
    notifyOnDisconnect() = settings.value(QStringLiteral("notifyOnDisconnect"), true).toBool();
    notifyOnInternalErrors() = settings.value(QStringLiteral("notifyOnErrors"), true).toBool();
    notifyOnSyncComplete() = settings.value(QStringLiteral("notifyOnSyncComplete"), true).toBool();
    showSyncthingNotifications() = settings.value(QStringLiteral("showSyncthingNotifications"), true).toBool();
    showTraffic() = settings.value(QStringLiteral("showTraffic"), true).toBool();
    trayMenuSize() = settings.value(QStringLiteral("trayMenuSize"), trayMenuSize()).toSize();
    frameStyle() = settings.value(QStringLiteral("frameStyle"), frameStyle()).toInt();
    settings.endGroup();

    settings.beginGroup(QStringLiteral("startup"));
    launchSynchting() = settings.value(QStringLiteral("launchSynchting"), false).toBool();
    syncthingPath() = settings.value(QStringLiteral("syncthingPath"), syncthingPath()).toString();
    syncthingArgs() = settings.value(QStringLiteral("syncthingArgs"), syncthingArgs()).toString();
    settings.endGroup();

#if defined(SYNCTHINGTRAY_USE_WEBENGINE) || defined(SYNCTHINGTRAY_USE_WEBKIT)
    settings.beginGroup(QStringLiteral("webview"));
    webViewDisabled() = settings.value(QStringLiteral("isabled"), false).toBool();
    webViewZoomFactor() = settings.value(QStringLiteral("zoomFactor"), 1.0).toDouble();
    webViewGeometry() = settings.value(QStringLiteral("geometry")).toByteArray();
    webViewKeepRunning() = settings.value(QStringLiteral("keepRunning"), true).toBool();
    settings.endGroup();
#endif

    qtSettings().restore(settings);
}

void save()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope,  QApplication::organizationName(), QApplication::applicationName());

    settings.beginGroup(QStringLiteral("tray"));
    settings.setValue(QStringLiteral("syncthingUrl"), syncthingUrl());
    settings.setValue(QStringLiteral("authEnabled"), authEnabled());
    settings.setValue(QStringLiteral("userName"), userName());
    settings.setValue(QStringLiteral("password"), password());
    settings.setValue(QStringLiteral("apiKey"), apiKey());
    settings.setValue(QStringLiteral("notifyOnDisconnect"), notifyOnDisconnect());
    settings.setValue(QStringLiteral("notifyOnErrors"), notifyOnInternalErrors());
    settings.setValue(QStringLiteral("notifyOnSyncComplete"), notifyOnSyncComplete());
    settings.setValue(QStringLiteral("showSyncthingNotifications"), showSyncthingNotifications());
    settings.setValue(QStringLiteral("showTraffic"), showTraffic());
    settings.setValue(QStringLiteral("trayMenuSize"), trayMenuSize());
    settings.setValue(QStringLiteral("frameStyle"), frameStyle());
    settings.endGroup();

    settings.beginGroup(QStringLiteral("startup"));
    settings.setValue(QStringLiteral("launchSynchting"), launchSynchting());
    settings.setValue(QStringLiteral("syncthingPath"), syncthingPath());
    settings.setValue(QStringLiteral("syncthingArgs"), syncthingArgs());
    settings.endGroup();

#if defined(SYNCTHINGTRAY_USE_WEBENGINE) || defined(SYNCTHINGTRAY_USE_WEBKIT)
    settings.beginGroup(QStringLiteral("webview"));
    settings.setValue(QStringLiteral("disabled"), webViewDisabled());
    settings.setValue(QStringLiteral("zoomFactor"), webViewZoomFactor());
    settings.setValue(QStringLiteral("geometry"), webViewGeometry());
    settings.setValue(QStringLiteral("keepRunning"), webViewKeepRunning());
    settings.endGroup();
#endif

    qtSettings().save(settings);
}

}
