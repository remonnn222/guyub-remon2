package logger

import (
	"os"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var Log *zap.SugaredLogger

func Init(level string, format string) error {
	var zapLevel zapcore.Level
	switch level {
	case "debug":
		zapLevel = zapcore.DebugLevel
	case "info":
		zapLevel = zapcore.InfoLevel
	case "warn":
		zapLevel = zapcore.WarnLevel
	case "error":
		zapLevel = zapcore.ErrorLevel
	default:
		zapLevel = zapcore.InfoLevel
	}

	var encoder zapcore.Encoder
	encoderConfig := zap.NewProductionEncoderConfig()
	encoderConfig.TimeKey = "timestamp"
	encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	encoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder

	if format == "console" {
		encoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
		encoder = zapcore.NewConsoleEncoder(encoderConfig)
	} else {
		encoder = zapcore.NewJSONEncoder(encoderConfig)
	}

	core := zapcore.NewCore(
		encoder,
		zapcore.AddSync(os.Stdout),
		zapLevel,
	)

	logger := zap.New(core, zap.AddCaller(), zap.AddStacktrace(zapcore.ErrorLevel))
	Log = logger.Sugar()

	return nil
}

func Sync() {
	if Log != nil {
		_ = Log.Sync()
	}
}

// Helper functions
func Debug(args ...interface{}) {
	Log.Debug(args...)
}

func Debugf(template string, args ...interface{}) {
	Log.Debugf(template, args...)
}

func Info(args ...interface{}) {
	Log.Info(args...)
}

func Infof(template string, args ...interface{}) {
	Log.Infof(template, args...)
}

func Warn(args ...interface{}) {
	Log.Warn(args...)
}

func Warnf(template string, args ...interface{}) {
	Log.Warnf(template, args...)
}

func Error(args ...interface{}) {
	Log.Error(args...)
}

func Errorf(template string, args ...interface{}) {
	Log.Errorf(template, args...)
}

func Fatal(args ...interface{}) {
	Log.Fatal(args...)
}

func Fatalf(template string, args ...interface{}) {
	Log.Fatalf(template, args...)
}
