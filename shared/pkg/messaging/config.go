package messaging

// Config contiene la configuración para RabbitMQ
type Config struct {
	// URL de conexión a RabbitMQ
	// Formato: amqp://user:password@host:port/vhost
	URL string

	// Exchange configuración del exchange
	Exchange ExchangeConfig

	// Queue configuración de la cola
	Queue QueueConfig

	// Consumer configuración del consumidor
	Consumer ConsumerConfig

	// PrefetchCount número de mensajes a pre-cargar
	PrefetchCount int
}

// ExchangeConfig configuración del exchange
type ExchangeConfig struct {
	Name       string // Nombre del exchange
	Type       string // Tipo: direct, topic, fanout, headers
	Durable    bool   // Persistente al reinicio
	AutoDelete bool   // Auto-eliminar cuando no hay bindings
}

// QueueConfig configuración de la cola
type QueueConfig struct {
	Name       string                 // Nombre de la cola
	Durable    bool                   // Persistente al reinicio
	AutoDelete bool                   // Auto-eliminar cuando no hay consumidores
	Exclusive  bool                   // Exclusiva para esta conexión
	Args       map[string]interface{} // Argumentos adicionales (priority, TTL, etc.)
}

// ConsumerConfig configuración del consumidor
type ConsumerConfig struct {
	Name      string // Nombre del consumidor
	AutoAck   bool   // Auto-acknowledge
	Exclusive bool   // Exclusivo
	NoLocal   bool   // No recibir mensajes publicados en la misma conexión
}

// DefaultConfig retorna una configuración con valores por defecto
func DefaultConfig() Config {
	return Config{
		URL: "amqp://guest:guest@localhost:5672/",
		Exchange: ExchangeConfig{
			Name:       "default_exchange",
			Type:       "topic",
			Durable:    true,
			AutoDelete: false,
		},
		Queue: QueueConfig{
			Name:       "default_queue",
			Durable:    true,
			AutoDelete: false,
			Exclusive:  false,
			Args:       make(map[string]interface{}),
		},
		Consumer: ConsumerConfig{
			Name:      "default_consumer",
			AutoAck:   false,
			Exclusive: false,
			NoLocal:   false,
		},
		PrefetchCount: 5,
	}
}
