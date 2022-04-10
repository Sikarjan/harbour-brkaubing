#include "tempfile.h"

TempFile::TempFile(QObject *parent) : QObject(parent)
{

}

void TempFile::shareCalEvent(const QString &event)
{
    QTemporaryFile *tmpFile = new QTemporaryFile(
        QDir::tempPath() + QDir::separator() + "event-XXXXXX.ics",
        this); // destructed and file deleted with this object

      if (tmpFile->open()) {
        QTextStream stream( tmpFile );
        stream << "BEGIN:VCALENDAR" << '\n'
               << "VERSION:2.0" << '\n'
               << "CALSCALE:GREGORIAN" << '\n'
               << "PRODID:-//BRK Aubing//EN" << '\n'
               << "METHOD:PUBLISH" << '\n'
               << event << '\n'
               << "END:VCALENDAR" << '\n';
        tmpFile->close();

        qDebug() << "Opening" << tmpFile->fileName();
        if (!QDesktopServices::openUrl(QUrl("file://" + tmpFile->fileName(), QUrl::TolerantMode))) {
          qWarning() << "QDesktopServices::openUrl fails!";
        }
    }
}
