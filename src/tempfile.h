#ifndef TEMPFILE_H
#define TEMPFILE_H

#include <QObject>
#include <QTemporaryFile>
#include <QDir>
#include <QUrl>
#include <QDesktopServices>

#include <QDebug>

class TempFile : public QObject
{
    Q_OBJECT
public:
    explicit TempFile(QObject *parent = nullptr);

    Q_INVOKABLE void shareCalEvent(const QString &event);

signals:

};

#endif // TEMPFILE_H
