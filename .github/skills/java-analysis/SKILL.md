---
name: java-analysis
description: Java code analysis patterns for Spring Boot, Maven/Gradle projects, REST APIs, and microservices. Use when analyzing Java codebases.
license: MIT
---

# Java Code Analysis Skill

This skill provides specialized knowledge for analyzing Java applications, particularly Spring Boot microservices, REST APIs, and enterprise Java applications.

## When to Use This Skill

Use this skill when analyzing:
- Java source files (`.java`)
- Spring Boot applications
- Maven projects (`pom.xml`)
- Gradle projects (`build.gradle`, `build.gradle.kts`)
- REST APIs and microservices
- JPA/Hibernate data access
- Spring configurations

## File Type Patterns

### Search Patterns
```
**/*.java                           # Java source files
**/pom.xml                          # Maven projects
**/build.gradle*                    # Gradle projects
**/application.properties           # Spring Boot config
**/application.yml                  # Spring Boot YAML config
**/src/main/java/**/*.java         # Main source
**/src/test/java/**/*.java         # Test source
**/src/main/resources/**/*         # Resources
```

## Entry Point Detection

### Spring Boot Application
```java
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}

* Look for:
- @SpringBootApplication annotation
- main() method
- Application.java or *Application.java naming pattern
```

### REST Controllers (HTTP Endpoints)
```java
@RestController
@RequestMapping("/api/customers")
public class CustomerController {
    
    @GetMapping("/{id}")
    public ResponseEntity<Customer> getCustomer(@PathVariable Long id) {
        // Entry point for GET /api/customers/{id}
    }
    
    @PostMapping
    public ResponseEntity<Customer> createCustomer(@RequestBody Customer customer) {
        // Entry point for POST /api/customers
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Customer> updateCustomer(
        @PathVariable Long id, 
        @RequestBody Customer customer) {
        // Entry point for PUT /api/customers/{id}
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCustomer(@PathVariable Long id) {
        // Entry point for DELETE /api/customers/{id}
    }
}

* Look for:
- @RestController or @Controller
- @RequestMapping, @GetMapping, @PostMapping, @PutMapping, @DeleteMapping
- @PathVariable, @RequestParam, @RequestBody
- HTTP method mapping
```

### Scheduled Jobs
```java
@Component
public class ScheduledTasks {
    
    @Scheduled(cron = "0 0 2 * * *")  // Daily at 2 AM
    public void dailyBatchJob() {
        // Scheduled entry point
    }
    
    @Scheduled(fixedRate = 60000)  // Every minute
    public void periodicTask() {
        // Periodic entry point
    }
}

* Look for:
- @Scheduled annotation
- Cron expressions or fixed rates
- @EnableScheduling in configuration
```

### Message Listeners (Async Processing)
```java
@Component
public class MessageListener {
    
    @RabbitListener(queues = "customer-queue")
    public void handleCustomerMessage(CustomerMessage message) {
        // Message queue entry point
    }
    
    @KafkaListener(topics = "orders")
    public void handleOrderEvent(OrderEvent event) {
        // Kafka topic entry point
    }
    
    @JmsListener(destination = "order-queue")
    public void processOrder(Order order) {
        // JMS queue entry point
    }
}

* Look for:
- @RabbitListener (RabbitMQ)
- @KafkaListener (Kafka)
- @JmsListener (JMS)
- @EventListener (Spring events)
```

### Event Handlers
```java
@Component
public class OrderEventHandler {
    
    @EventListener
    public void handleOrderCreated(OrderCreatedEvent event) {
        // Domain event handler
    }
    
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleAfterCommit(CustomerUpdatedEvent event) {
        // Post-transaction event handler
    }
}
```

## Data Structure Patterns

### Entity Classes (JPA/Hibernate)
```java
@Entity
@Table(name = "customers")
public class Customer {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String name;
    
    @Column(unique = true)
    private String email;
    
    @Enumerated(EnumType.STRING)
    private CustomerStatus status;
    
    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL)
    private List<Order> orders;
    
    @ManyToOne
    @JoinColumn(name = "account_id")
    private Account account;
    
    // Getters, setters
}

* Look for:
- @Entity annotation
- @Table for table mapping
- @Id for primary key
- @Column for field mapping
- @OneToMany, @ManyToOne, @ManyToMany for relationships
- @Enumerated for enums
```

### DTOs (Data Transfer Objects)
```java
public class CustomerDTO {
    private Long id;
    private String name;
    private String email;
    private String status;
    
    // Constructors, getters, setters
}

// Or with Lombok
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerDTO {
    private Long id;
    private String name;
    private String email;
    private String status;
}

* Look for:
- DTO, Dto suffix in class names
- @Data (Lombok)
- Request/Response suffix classes
- Simple POJOs with getters/setters
```

### Value Objects
```java
@Embeddable
public class Address {
    private String street;
    private String city;
    private String state;
    private String zipCode;
    
    // Value object methods
    public boolean isValid() {
        return street != null && city != null;
    }
}

@Entity
public class Customer {
    @Embedded
    private Address billingAddress;
}

* Look for:
- @Embeddable annotation
- Immutable classes
- No @Entity annotation
- Embedded in entities with @Embedded
```

### Enums
```java
public enum CustomerStatus {
    ACTIVE("Active"),
    INACTIVE("Inactive"),
    SUSPENDED("Suspended"),
    CLOSED("Closed");
    
    private final String displayName;
    
    CustomerStatus(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
```

## Flow Tracing Patterns

### Controller → Service → Repository Pattern
```java
// Controller layer (HTTP handling)
@RestController
@RequestMapping("/api/customers")
public class CustomerController {
    
    @Autowired
    private CustomerService customerService;
    
    @GetMapping("/{id}")
    public ResponseEntity<CustomerDTO> getCustomer(@PathVariable Long id) {
        CustomerDTO customer = customerService.findById(id);
        return ResponseEntity.ok(customer);
    }
}

// Service layer (Business logic)
@Service
@Transactional
public class CustomerService {
    
    @Autowired
    private CustomerRepository customerRepository;
    
    @Autowired
    private CustomerMapper customerMapper;
    
    public CustomerDTO findById(Long id) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new CustomerNotFoundException(id));
        return customerMapper.toDTO(customer);
    }
}

// Repository layer (Data access)
@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    Optional<Customer> findByEmail(String email);
    List<Customer> findByStatus(CustomerStatus status);
}

* Flow: Controller → Service → Repository → Database
* Look for:
- @Controller/@RestController → HTTP layer
- @Service → Business logic layer
- @Repository → Data access layer
- Dependency injection with @Autowired or constructor injection
```

### Decision Points (Business Logic)
```java
@Service
public class OrderService {
    
    public OrderResult processOrder(OrderRequest request) {
        // Validation
        if (!isValidOrder(request)) {
            throw new InvalidOrderException("Order validation failed");
        }
        
        // Business rule: Check inventory
        if (inventoryService.getStock(request.getProductId()) < request.getQuantity()) {
            return OrderResult.outOfStock();
        }
        
        // Business rule: Apply discount
        BigDecimal finalPrice = request.getPrice();
        if (customerService.isPremiumCustomer(request.getCustomerId())) {
            finalPrice = applyPremiumDiscount(finalPrice);
        } else if (request.getQuantity() > 10) {
            finalPrice = applyBulkDiscount(finalPrice);
        }
        
        // Process payment
        PaymentResult payment = paymentService.processPayment(
            request.getCustomerId(), finalPrice);
            
        if (!payment.isSuccessful()) {
            return OrderResult.paymentFailed(payment.getError());
        }
        
        // Create order
        Order order = orderRepository.save(
            Order.builder()
                .customerId(request.getCustomerId())
                .productId(request.getProductId())
                .quantity(request.getQuantity())
                .totalPrice(finalPrice)
                .status(OrderStatus.CONFIRMED)
                .build()
        );
        
        return OrderResult.success(order);
    }
}

* Look for:
- if/else statements encoding business rules
- Switch statements for state machines
- Validation logic
- Calculation logic
- State transitions
```

### Transaction Management
```java
@Service
public class TransferService {
    
    @Transactional
    public void transferFunds(Long fromAccountId, Long toAccountId, BigDecimal amount) {
        // All operations in one transaction
        Account from = accountRepository.findById(fromAccountId).orElseThrow();
        Account to = accountRepository.findById(toAccountId).orElseThrow();
        
        from.withdraw(amount);
        to.deposit(amount);
        
        accountRepository.save(from);
        accountRepository.save(to);
        
        // Commits on success, rolls back on exception
    }
    
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void logActivity(String activity) {
        // Independent transaction
    }
}

* Look for:
- @Transactional annotations
- Transaction propagation settings
- Rollback rules
```

## Integration Pattern Detection

### Database Access (JPA/Hibernate)
```java
// Repository with custom queries
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    // Query method derived from method name
    List<Order> findByCustomerIdAndStatus(Long customerId, OrderStatus status);
    
    // Custom JPQL query
    @Query("SELECT o FROM Order o WHERE o.totalAmount > :amount")
    List<Order> findLargeOrders(@Param("amount") BigDecimal amount);
    
    // Native SQL query
    @Query(value = "SELECT * FROM orders WHERE created_date > ?1", nativeQuery = true)
    List<Order> findRecentOrders(Date since);
    
    // Modifying query
    @Modifying
    @Query("UPDATE Order o SET o.status = :status WHERE o.id = :id")
    void updateStatus(@Param("id") Long id, @Param("status") OrderStatus status);
}
```

### REST API Clients (Feign/RestTemplate)
```java
// Feign client
@FeignClient(name = "payment-service", url = "${payment.service.url}")
public interface PaymentClient {
    
    @PostMapping("/payments")
    PaymentResponse processPayment(@RequestBody PaymentRequest request);
    
    @GetMapping("/payments/{id}")
    Payment getPayment(@PathVariable("id") String paymentId);
}

// RestTemplate usage
@Service
public class ExternalApiService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    public CustomerData fetchCustomerData(String customerId) {
        String url = "https://api.example.com/customers/" + customerId;
        return restTemplate.getForObject(url, CustomerData.class);
    }
}

* Look for:
- @FeignClient annotations
- RestTemplate beans and usage
- WebClient for reactive APIs
- HTTP method calls
```

### Message Queues (RabbitMQ/Kafka)
```java
// RabbitMQ Producer
@Service
public class OrderEventPublisher {
    
    @Autowired
    private RabbitTemplate rabbitTemplate;
    
    public void publishOrderCreated(Order order) {
        OrderCreatedEvent event = new OrderCreatedEvent(order);
        rabbitTemplate.convertAndSend("order-exchange", "order.created", event);
    }
}

// Kafka Producer
@Service
public class EventProducer {
    
    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    public void sendOrderEvent(OrderEvent event) {
        kafkaTemplate.send("orders-topic", event.getOrderId(), event);
    }
}

* Look for:
- RabbitTemplate, KafkaTemplate
- @RabbitListener, @KafkaListener
- Queue/topic names
- Message serialization
```

### Caching
```java
@Service
public class CustomerService {
    
    @Cacheable(value = "customers", key = "#id")
    public Customer findById(Long id) {
        return customerRepository.findById(id).orElseThrow();
    }
    
    @CacheEvict(value = "customers", key = "#customer.id")
    public Customer update(Customer customer) {
        return customerRepository.save(customer);
    }
    
    @CachePut(value = "customers", key = "#result.id")
    public Customer create(Customer customer) {
        return customerRepository.save(customer);
    }
}

* Look for:
- @Cacheable, @CacheEvict, @CachePut
- Cache names and keys
- @EnableCaching in configuration
```

## Error Handling Patterns

### Exception Handling
```java
// Custom exceptions
public class CustomerNotFoundException extends RuntimeException {
    public CustomerNotFoundException(Long customerId) {
        super("Customer not found: " + customerId);
    }
}

public class InvalidOrderException extends RuntimeException {
    public InvalidOrderException(String message) {
        super(message);
    }
}

// Global exception handler
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(CustomerNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleCustomerNotFound(
        CustomerNotFoundException ex) {
        ErrorResponse error = new ErrorResponse("NOT_FOUND", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(InvalidOrderException.class)
    public ResponseEntity<ErrorResponse> handleInvalidOrder(
        InvalidOrderException ex) {
        ErrorResponse error = new ErrorResponse("INVALID_ORDER", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "An error occurred");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}

* Look for:
- Custom exception classes
- @RestControllerAdvice or @ControllerAdvice
- @ExceptionHandler methods
- Error response structures
```

### Validation
```java
public class CustomerRequest {
    
    @NotNull(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;
    
    @Email(message = "Invalid email format")
    @NotBlank(message = "Email is required")
    private String email;
    
    @Pattern(regexp = "^\\d{10}$", message = "Phone must be 10 digits")
    private String phone;
    
    @Min(value = 18, message = "Age must be at least 18")
    private Integer age;
}

@RestController
public class CustomerController {
    
    @PostMapping("/customers")
    public ResponseEntity<Customer> createCustomer(
        @Valid @RequestBody CustomerRequest request) {
        // @Valid triggers validation
    }
}

* Look for:
- javax.validation or jakarta.validation annotations
- @Valid annotation on parameters
- Custom validators
```

## Configuration Patterns

### Application Properties/YAML
```yaml
# application.yml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: ${DB_USER}
    password: ${DB_PASSWORD}
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
  
  rabbitmq:
    host: ${RABBITMQ_HOST:localhost}
    port: 5672

custom:
  api:
    base-url: https://api.example.com
    timeout: 5000
```

### Configuration Classes
```java
@Configuration
public class AppConfig {
    
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
    
    @Bean
    @ConfigurationProperties(prefix = "custom.api")
    public ApiConfig apiConfig() {
        return new ApiConfig();
    }
}

@ConfigurationProperties(prefix = "custom.api")
@Data
public class ApiConfig {
    private String baseUrl;
    private int timeout;
}

* Look for:
- @Configuration classes
- @Bean methods
- @ConfigurationProperties
- @Value injections
```

## Testing Patterns

### Unit Tests
```java
@ExtendWith(MockitoExtension.class)
class CustomerServiceTest {
    
    @Mock
    private CustomerRepository customerRepository;
    
    @InjectMocks
    private CustomerService customerService;
    
    @Test
    void testFindById_Success() {
        // Given
        Long customerId = 1L;
        Customer customer = new Customer();
        customer.setId(customerId);
        when(customerRepository.findById(customerId))
            .thenReturn(Optional.of(customer));
        
        // When
        CustomerDTO result = customerService.findById(customerId);
        
        // Then
        assertNotNull(result);
        assertEquals(customerId, result.getId());
        verify(customerRepository).findById(customerId);
    }
}

* Look for:
- @Test annotations (JUnit)
- @Mock, @InjectMocks (Mockito)
- when().thenReturn() mocking
- verify() calls
```

### Integration Tests
```java
@SpringBootTest
@AutoConfigureMockMvc
class CustomerControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private CustomerRepository customerRepository;
    
    @Test
    void testCreateCustomer() throws Exception {
        String customerJson = "{\"name\":\"John Doe\",\"email\":\"john@example.com\"}";
        
        mockMvc.perform(post("/api/customers")
                .contentType(MediaType.APPLICATION_JSON)
                .content(customerJson))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("John Doe"))
            .andExpect(jsonPath("$.email").value("john@example.com"));
    }
}

* Look for:
- @SpringBootTest
- @AutoConfigureMockMvc
- MockMvc usage
- HTTP method testing
```

## Best Practices for Discovery

1. **Start with @SpringBootApplication** - Find main entry point
2. **Map REST endpoints** - Document all @RestController methods
3. **Trace service layer** - Follow business logic flow
4. **Identify repositories** - Map database access patterns
5. **Document integrations** - External APIs, queues, caching
6. **Extract business rules** - From service layer logic
7. **Note transaction boundaries** - @Transactional usage
8. **Identify async processing** - @Async, message listeners
9. **Map security** - @PreAuthorize, @Secured annotations
10. **Document configuration** - application.yml, @ConfigurationProperties

## Output Format

When documenting Java flows, include:

```markdown
## Flow: [Flow Name]
- **Entry Point**: GET /api/customers/{id} (CustomerController.getCustomer)
- **Layer Flow**: Controller → Service → Repository
- **Input**: PathVariable customerId
- **Processing**:
  1. CustomerController receives request
  2. Calls CustomerService.findById(id)
  3. Service queries CustomerRepository
  4. Maps entity to DTO
  5. Returns DTO to controller
- **Output**: CustomerDTO JSON response
- **Integration**:
  - Database: PostgreSQL via JPA
  - Cache: Redis (customer cache)
- **Error Handling**: 
  - 404 if customer not found
  - 500 for database errors
- **Transaction**: Read-only
- **Dependencies**:
  - Services: CustomerService
  - Repositories: CustomerRepository
  - DTOs: CustomerDTO
  - Entities: Customer
```

This skill enables comprehensive documentation of Java/Spring Boot applications.
