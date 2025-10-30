package errors

import (
	"fmt"
	"net/http"
)

// ErrorCode representa un código de error único
type ErrorCode string

const (
	// Errores de validación
	ErrorCodeValidation ErrorCode = "VALIDATION_ERROR"
	ErrorCodeInvalidInput ErrorCode = "INVALID_INPUT"

	// Errores de recursos
	ErrorCodeNotFound ErrorCode = "NOT_FOUND"
	ErrorCodeAlreadyExists ErrorCode = "ALREADY_EXISTS"
	ErrorCodeConflict ErrorCode = "CONFLICT"

	// Errores de autenticación y autorización
	ErrorCodeUnauthorized ErrorCode = "UNAUTHORIZED"
	ErrorCodeForbidden ErrorCode = "FORBIDDEN"
	ErrorCodeInvalidToken ErrorCode = "INVALID_TOKEN"
	ErrorCodeTokenExpired ErrorCode = "TOKEN_EXPIRED"

	// Errores de negocio
	ErrorCodeBusinessRule ErrorCode = "BUSINESS_RULE_VIOLATION"
	ErrorCodeInvalidState ErrorCode = "INVALID_STATE"

	// Errores del sistema
	ErrorCodeInternal ErrorCode = "INTERNAL_ERROR"
	ErrorCodeDatabaseError ErrorCode = "DATABASE_ERROR"
	ErrorCodeExternalService ErrorCode = "EXTERNAL_SERVICE_ERROR"
	ErrorCodeTimeout ErrorCode = "TIMEOUT"

	// Errores de límites
	ErrorCodeRateLimit ErrorCode = "RATE_LIMIT_EXCEEDED"
	ErrorCodeQuotaExceeded ErrorCode = "QUOTA_EXCEEDED"
)

// AppError es el error personalizado de la aplicación
type AppError struct {
	Code       ErrorCode              // Código único de error
	Message    string                 // Mensaje legible para humanos
	Details    string                 // Detalles adicionales (opcional)
	StatusCode int                    // Código HTTP sugerido
	Internal   error                  // Error interno original (no expuesto al cliente)
	Fields     map[string]interface{} // Campos adicionales para contexto
}

// Error implementa la interfaz error
func (e *AppError) Error() string {
	if e.Internal != nil {
		return fmt.Sprintf("%s: %s (internal: %v)", e.Code, e.Message, e.Internal)
	}
	return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

// Unwrap permite usar errors.Is y errors.As
func (e *AppError) Unwrap() error {
	return e.Internal
}

// WithDetails agrega detalles adicionales al error
func (e *AppError) WithDetails(details string) *AppError {
	e.Details = details
	return e
}

// WithField agrega un campo de contexto
func (e *AppError) WithField(key string, value interface{}) *AppError {
	if e.Fields == nil {
		e.Fields = make(map[string]interface{})
	}
	e.Fields[key] = value
	return e
}

// WithInternal agrega el error interno
func (e *AppError) WithInternal(err error) *AppError {
	e.Internal = err
	return e
}

// New crea un nuevo AppError
func New(code ErrorCode, message string) *AppError {
	return &AppError{
		Code:       code,
		Message:    message,
		StatusCode: getDefaultStatusCode(code),
		Fields:     make(map[string]interface{}),
	}
}

// Wrap envuelve un error existente en un AppError
func Wrap(err error, code ErrorCode, message string) *AppError {
	return &AppError{
		Code:       code,
		Message:    message,
		StatusCode: getDefaultStatusCode(code),
		Internal:   err,
		Fields:     make(map[string]interface{}),
	}
}

// Constructores de errores comunes

// NewValidationError crea un error de validación
func NewValidationError(message string) *AppError {
	return New(ErrorCodeValidation, message)
}

// NewNotFoundError crea un error de recurso no encontrado
func NewNotFoundError(resource string) *AppError {
	return New(ErrorCodeNotFound, fmt.Sprintf("%s not found", resource)).
		WithField("resource", resource)
}

// NewAlreadyExistsError crea un error de recurso ya existente
func NewAlreadyExistsError(resource string) *AppError {
	return New(ErrorCodeAlreadyExists, fmt.Sprintf("%s already exists", resource)).
		WithField("resource", resource)
}

// NewUnauthorizedError crea un error de no autorizado
func NewUnauthorizedError(message string) *AppError {
	if message == "" {
		message = "unauthorized"
	}
	return New(ErrorCodeUnauthorized, message)
}

// NewForbiddenError crea un error de acceso prohibido
func NewForbiddenError(message string) *AppError {
	if message == "" {
		message = "forbidden"
	}
	return New(ErrorCodeForbidden, message)
}

// NewInternalError crea un error interno del servidor
func NewInternalError(message string, err error) *AppError {
	if message == "" {
		message = "internal server error"
	}
	return Wrap(err, ErrorCodeInternal, message)
}

// NewDatabaseError crea un error de base de datos
func NewDatabaseError(operation string, err error) *AppError {
	return Wrap(err, ErrorCodeDatabaseError, fmt.Sprintf("database error during %s", operation)).
		WithField("operation", operation)
}

// NewBusinessRuleError crea un error de regla de negocio
func NewBusinessRuleError(message string) *AppError {
	return New(ErrorCodeBusinessRule, message)
}

// NewConflictError crea un error de conflicto
func NewConflictError(message string) *AppError {
	return New(ErrorCodeConflict, message)
}

// NewRateLimitError crea un error de límite de tasa excedido
func NewRateLimitError() *AppError {
	return New(ErrorCodeRateLimit, "rate limit exceeded")
}

// getDefaultStatusCode retorna el código HTTP por defecto para cada ErrorCode
func getDefaultStatusCode(code ErrorCode) int {
	switch code {
	case ErrorCodeValidation, ErrorCodeInvalidInput:
		return http.StatusBadRequest
	case ErrorCodeNotFound:
		return http.StatusNotFound
	case ErrorCodeAlreadyExists, ErrorCodeConflict:
		return http.StatusConflict
	case ErrorCodeUnauthorized, ErrorCodeInvalidToken, ErrorCodeTokenExpired:
		return http.StatusUnauthorized
	case ErrorCodeForbidden:
		return http.StatusForbidden
	case ErrorCodeBusinessRule, ErrorCodeInvalidState:
		return http.StatusUnprocessableEntity
	case ErrorCodeRateLimit:
		return http.StatusTooManyRequests
	case ErrorCodeTimeout:
		return http.StatusRequestTimeout
	case ErrorCodeDatabaseError, ErrorCodeInternal, ErrorCodeExternalService:
		return http.StatusInternalServerError
	default:
		return http.StatusInternalServerError
	}
}

// IsAppError verifica si un error es un AppError
func IsAppError(err error) bool {
	_, ok := err.(*AppError)
	return ok
}

// GetAppError intenta convertir un error a AppError
func GetAppError(err error) (*AppError, bool) {
	appErr, ok := err.(*AppError)
	return appErr, ok
}
