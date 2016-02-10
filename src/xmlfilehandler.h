#ifndef XMLFILEHANDLER_H
#define XMLFILEHANDLER_H

#include <QObject>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QStandardPaths>
#include <QTextStream>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QDateTime>
#include <QXmlStreamReader>
#include <QList>
#include <QDebug>

class XmlFileHandler : public QObject
{
    Q_OBJECT
public:
    explicit XmlFileHandler(QObject *parent = 0);
    Q_PROPERTY(int fileStat READ fileStat WRITE setFileStat NOTIFY fileStatChanged)
    Q_PROPERTY(QList<QString> nextEventsArray READ nextEventsArray WRITE setNextEventsArray NOTIFY nextEventsArrayChanged)

    Q_INVOKABLE void load(const QString &filePath, const QString &fileName);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QString filePath();

    int fileStat();
    QList<QString> nextEventsArray() const { return nextEvents;}
    void nextEvent();

signals:
    void fileStatChanged(int stat);
    void nextEventsArrayChanged();

public slots:
    void setFileStat(int curStat);
    void setNextEventsArray(QList<QString>);
    void replyFinished (QNetworkReply *reply);
    void getHeaders (QNetworkReply *reply);
    void catchFileStatChange(int stat);

private:
   int stat;
   int nextOpenBa;
   int nextIntBa;
   QDir fileLocation;
   QUrl url;
   QString fileUrl;
   QFileInfo xmlInfo;
   QNetworkAccessManager *manager;
   QNetworkAccessManager *headManager;
   QList<QString> nextEvents;
   QStringList event;
   QDateTime timeStamp;
};

#endif // XMLFILEHANDLER_H
