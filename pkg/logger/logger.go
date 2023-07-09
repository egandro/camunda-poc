package logger

import (
	"io"
	"log"
	"os"

	"github.com/sirupsen/logrus"
)

type Logger struct {
	Logger *log.Logger
	Logrus *logrus.Logger
	writer *io.PipeWriter
}

var instance *Logger = nil

// todo - implement opts pattern: https://www.sohamkamani.com/golang/options-pattern/
// disable timestamp

func Get() *Logger {
	if instance != nil {
		return instance
	}

	logrusLogger := logrus.New()
	logrusLogger.Out = os.Stdout

	instance := &Logger{log.Default(), logrusLogger, logrusLogger.Writer()}
	instance.Logger.SetFlags(0)

	const format = "json"
	if format == "json" {
		// Log as JSON instead of the default ASCII formatter.
		// customize the fields
		var formatter = &logrus.JSONFormatter{
			DisableTimestamp: true,
			FieldMap: logrus.FieldMap{
				logrus.FieldKeyTime:  "timestamp",
				logrus.FieldKeyLevel: "level",
				logrus.FieldKeyMsg:   "message",
				logrus.FieldKeyFunc:  "caller",
			},
		}
		logrusLogger.SetFormatter(formatter)
		log.SetOutput(instance.writer)
	} else {
		var formatter = &logrus.TextFormatter{
			DisableTimestamp: true,
			FieldMap: logrus.FieldMap{
				logrus.FieldKeyTime:  "timestamp",
				logrus.FieldKeyLevel: "level",
				logrus.FieldKeyMsg:   "message",
				logrus.FieldKeyFunc:  "caller",
			},
		}
		logrusLogger.SetFormatter(formatter)
		log.SetOutput(instance.writer)
	}

	// https://stackoverflow.com/questions/47514812/how-to-use-debug-log-in-golang
	lvl, ok := os.LookupEnv("LOG_LEVEL")
	// LOG_LEVEL not set, let's default to debug
	if !ok {
		lvl = "debug"
	}
	// parse string, this is built-in feature of logrus
	ll, err := logrus.ParseLevel(lvl)
	if err != nil {
		ll = logrus.DebugLevel
	}
	// set global log level
	logrusLogger.SetLevel(ll)

	return instance
}

func (l *Logger) Close() {
	if l.writer != nil {
		l.writer.Close()
	}
	instance = nil
}
