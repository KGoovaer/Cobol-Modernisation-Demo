---
name: typescript-analysis
description: TypeScript/JavaScript code analysis for Node.js, React, Angular, Express, and frontend/backend applications. Use when analyzing TypeScript or modern JavaScript codebases.
license: MIT
---

# TypeScript/JavaScript Code Analysis Skill

This skill provides specialized knowledge for analyzing TypeScript and JavaScript applications, including Node.js backends, React frontends, Angular applications, and Express APIs.

## When to Use This Skill

Use this skill when analyzing:
- TypeScript files (`.ts`, `.tsx`)
- JavaScript files (`.js`, `.jsx`)
- Node.js applications
- React applications
- Angular applications
- Express.js APIs
- Next.js applications
- NestJS applications

## File Type Patterns

### Search Patterns
```
**/*.ts                             # TypeScript files
**/*.tsx                            # TypeScript React components
**/*.js                             # JavaScript files
**/*.jsx                            # JavaScript React components
**/package.json                     # NPM project definition
**/tsconfig.json                    # TypeScript configuration
**/angular.json                     # Angular configuration
**/next.config.js                   # Next.js configuration
**/nest-cli.json                    # NestJS configuration
**/src/**/*.{ts,tsx,js,jsx}        # Source files
**/test/**/*.{ts,js}               # Test files
**/__tests__/**/*.{ts,js}          # Jest tests
```

## Entry Point Detection

### Node.js/Express Application
```typescript
// Main application file (index.ts, server.ts, app.ts)
import express from 'express';
import { router as customerRouter } from './routes/customers';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use('/api/customers', customerRouter);

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

* Look for:
- Express app initialization
- Route mounting (app.use, app.get, app.post)
- Server listen call
- Main entry in package.json scripts
```

### NestJS Application
```typescript
// main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);
    await app.listen(3000);
}
bootstrap();

// app.module.ts
@Module({
    imports: [CustomerModule, OrderModule],
    controllers: [AppController],
    providers: [AppService],
})
export class AppModule {}

* Look for:
- @Module decorators
- NestFactory.create()
- Module imports and providers
- main.ts bootstrap function
```

### REST API Controllers (Express)
```typescript
// Express router
import { Router } from 'express';
import { CustomerController } from './customer.controller';

const router = Router();
const controller = new CustomerController();

// GET /api/customers/:id
router.get('/:id', async (req, res) => {
    const customer = await controller.getById(req.params.id);
    res.json(customer);
});

// POST /api/customers
router.post('/', async (req, res) => {
    const customer = await controller.create(req.body);
    res.status(201).json(customer);
});

// PUT /api/customers/:id
router.put('/:id', async (req, res) => {
    const customer = await controller.update(req.params.id, req.body);
    res.json(customer);
});

// DELETE /api/customers/:id
router.delete('/:id', async (req, res) => {
    await controller.delete(req.params.id);
    res.status(204).send();
});

* Look for:
- Router instance creation
- HTTP method handlers (get, post, put, delete, patch)
- Route parameters (:id)
- Request/response handling
```

### NestJS Controllers
```typescript
@Controller('customers')
export class CustomerController {
    constructor(private readonly customerService: CustomerService) {}
    
    @Get(':id')
    async getCustomer(@Param('id') id: string): Promise<CustomerDto> {
        return this.customerService.findById(id);
    }
    
    @Post()
    async createCustomer(@Body() createDto: CreateCustomerDto): Promise<CustomerDto> {
        return this.customerService.create(createDto);
    }
    
    @Put(':id')
    async updateCustomer(
        @Param('id') id: string,
        @Body() updateDto: UpdateCustomerDto
    ): Promise<CustomerDto> {
        return this.customerService.update(id, updateDto);
    }
    
    @Delete(':id')
    @HttpCode(204)
    async deleteCustomer(@Param('id') id: string): Promise<void> {
        await this.customerService.delete(id);
    }
}

* Look for:
- @Controller decorator
- @Get, @Post, @Put, @Delete decorators
- @Param, @Body, @Query decorators
- Dependency injection in constructor
```

### React Components
```typescript
// Functional component
import React, { useState, useEffect } from 'react';

interface CustomerListProps {
    customerId?: string;
}

export const CustomerList: React.FC<CustomerListProps> = ({ customerId }) => {
    const [customers, setCustomers] = useState<Customer[]>([]);
    const [loading, setLoading] = useState(true);
    
    useEffect(() => {
        fetchCustomers();
    }, []);
    
    const fetchCustomers = async () => {
        const response = await fetch('/api/customers');
        const data = await response.json();
        setCustomers(data);
        setLoading(false);
    };
    
    return (
        <div>
            {loading ? <Spinner /> : <CustomerTable customers={customers} />}
        </div>
    );
};

* Look for:
- React.FC or function components
- useState, useEffect hooks
- Props interface
- JSX return statements
```

### Scheduled Jobs
```typescript
// Using node-cron
import cron from 'node-cron';

// Run every day at 2:00 AM
cron.schedule('0 2 * * *', async () => {
    console.log('Running daily batch job');
    await processDailyReports();
});

// Using NestJS @Cron
import { Cron } from '@nestjs/schedule';

@Injectable()
export class TasksService {
    @Cron('0 2 * * *')
    async handleDailyJob() {
        console.log('Running daily job');
    }
}

* Look for:
- cron.schedule calls
- @Cron decorator (NestJS)
- setInterval for periodic tasks
- Agenda, Bull queue scheduled jobs
```

### Event Handlers/Message Consumers
```typescript
// Event emitter pattern
import { EventEmitter } from 'events';

class OrderEventEmitter extends EventEmitter {}
const orderEvents = new OrderEventEmitter();

orderEvents.on('order.created', async (order: Order) => {
    // Event handler entry point
    await sendConfirmationEmail(order);
});

// RabbitMQ consumer
import amqp from 'amqplib';

async function consumeMessages() {
    const connection = await amqp.connect('amqp://localhost');
    const channel = await connection.createChannel();
    await channel.assertQueue('orders');
    
    channel.consume('orders', async (msg) => {
        if (msg) {
            const order = JSON.parse(msg.content.toString());
            await processOrder(order);
            channel.ack(msg);
        }
    });
}

* Look for:
- EventEmitter.on() handlers
- Message queue consumers (RabbitMQ, Kafka, Redis)
- WebSocket message handlers
- GraphQL subscriptions
```

## Data Structure Patterns

### TypeScript Interfaces & Types
```typescript
// Entity interface
export interface Customer {
    id: string;
    name: string;
    email: string;
    status: CustomerStatus;
    createdAt: Date;
    updatedAt: Date;
}

// Enum
export enum CustomerStatus {
    ACTIVE = 'ACTIVE',
    INACTIVE = 'INACTIVE',
    SUSPENDED = 'SUSPENDED',
    CLOSED = 'CLOSED'
}

// Type alias
export type CustomerId = string;
export type CustomerFilter = Partial<Customer>;

// Union types
export type OrderStatus = 'pending' | 'confirmed' | 'shipped' | 'delivered';

// Utility types
export type CreateCustomerDto = Omit<Customer, 'id' | 'createdAt' | 'updatedAt'>;
export type UpdateCustomerDto = Partial<CreateCustomerDto>;

* Look for:
- interface declarations
- type aliases
- enum definitions
- Generic types
- Utility types (Partial, Omit, Pick, etc.)
```

### DTOs (Data Transfer Objects)
```typescript
// Class-based DTO (NestJS with validation)
import { IsString, IsEmail, IsEnum, MinLength } from 'class-validator';

export class CreateCustomerDto {
    @IsString()
    @MinLength(2)
    name: string;
    
    @IsEmail()
    email: string;
    
    @IsEnum(CustomerStatus)
    status: CustomerStatus;
}

// Interface-based DTO
export interface CustomerResponseDto {
    id: string;
    name: string;
    email: string;
    status: string;
}

* Look for:
- DTO suffix in names
- Validation decorators (class-validator)
- Request/Response suffix
- Data mapping between entities and DTOs
```

### Database Models (TypeORM, Prisma, Mongoose)
```typescript
// TypeORM Entity
import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';

@Entity('customers')
export class Customer {
    @PrimaryGeneratedColumn('uuid')
    id: string;
    
    @Column({ length: 100 })
    name: string;
    
    @Column({ unique: true })
    email: string;
    
    @Column({ type: 'enum', enum: CustomerStatus })
    status: CustomerStatus;
    
    @OneToMany(() => Order, order => order.customer)
    orders: Order[];
    
    @Column({ type: 'timestamp' })
    createdAt: Date;
}

// Prisma Schema (schema.prisma)
model Customer {
    id        String   @id @default(uuid())
    name      String
    email     String   @unique
    status    String
    orders    Order[]
    createdAt DateTime @default(now())
}

// Mongoose Schema
import { Schema, model } from 'mongoose';

const customerSchema = new Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    status: { type: String, enum: ['ACTIVE', 'INACTIVE'] },
    createdAt: { type: Date, default: Date.now }
});

export const CustomerModel = model('Customer', customerSchema);

* Look for:
- @Entity decorator (TypeORM)
- Prisma schema files
- Mongoose Schema definitions
- Column/field decorators
- Relationships
```

## Flow Tracing Patterns

### Controller → Service → Repository Pattern
```typescript
// Controller layer
@Controller('orders')
export class OrderController {
    constructor(private readonly orderService: OrderService) {}
    
    @Post()
    async createOrder(@Body() createDto: CreateOrderDto): Promise<OrderDto> {
        return this.orderService.create(createDto);
    }
}

// Service layer (Business logic)
@Injectable()
export class OrderService {
    constructor(
        private readonly orderRepository: OrderRepository,
        private readonly customerService: CustomerService,
        private readonly inventoryService: InventoryService
    ) {}
    
    async create(createDto: CreateOrderDto): Promise<OrderDto> {
        // Validation
        const customer = await this.customerService.findById(createDto.customerId);
        if (!customer) {
            throw new NotFoundException('Customer not found');
        }
        
        // Business logic
        const stock = await this.inventoryService.checkStock(createDto.productId);
        if (stock < createDto.quantity) {
            throw new BadRequestException('Insufficient stock');
        }
        
        // Create order
        const order = await this.orderRepository.create({
            ...createDto,
            status: OrderStatus.PENDING,
            totalAmount: this.calculateTotal(createDto)
        });
        
        // Update inventory
        await this.inventoryService.reserveStock(
            createDto.productId,
            createDto.quantity
        );
        
        return this.mapToDto(order);
    }
    
    private calculateTotal(dto: CreateOrderDto): number {
        return dto.price * dto.quantity;
    }
}

// Repository layer (Data access)
@Injectable()
export class OrderRepository {
    constructor(
        @InjectRepository(Order)
        private readonly repository: Repository<Order>
    ) {}
    
    async create(data: Partial<Order>): Promise<Order> {
        const order = this.repository.create(data);
        return this.repository.save(order);
    }
    
    async findById(id: string): Promise<Order | null> {
        return this.repository.findOne({ where: { id } });
    }
}

* Flow: Controller → Service → Repository → Database
* Look for:
- Dependency injection in constructors
- Service method calls
- Repository/database access
- Business logic in services
- Mapping between entities and DTOs
```

### Async/Await Patterns
```typescript
async function processOrder(orderId: string): Promise<void> {
    try {
        // Sequential async operations
        const order = await orderRepository.findById(orderId);
        const customer = await customerRepository.findById(order.customerId);
        const payment = await paymentService.processPayment(order);
        
        // Parallel async operations
        const [inventory, shipping] = await Promise.all([
            inventoryService.updateStock(order),
            shippingService.createShipment(order)
        ]);
        
        // Update order
        await orderRepository.update(orderId, { status: 'CONFIRMED' });
    } catch (error) {
        console.error('Order processing failed:', error);
        throw error;
    }
}

* Look for:
- async/await keywords
- Promise chains
- Promise.all for parallel operations
- try/catch for error handling
```

### Middleware/Guards
```typescript
// Express middleware
export const authMiddleware = async (
    req: Request,
    res: Response,
    next: NextFunction
) => {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ error: 'Unauthorized' });
    }
    
    try {
        const payload = await verifyToken(token);
        req.user = payload;
        next();
    } catch (error) {
        return res.status(401).json({ error: 'Invalid token' });
    }
};

// NestJS Guard
@Injectable()
export class AuthGuard implements CanActivate {
    canActivate(context: ExecutionContext): boolean | Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        return this.validateRequest(request);
    }
    
    private validateRequest(request: any): boolean {
        // Validation logic
        return true;
    }
}

* Look for:
- Middleware functions (Express)
- Guards (NestJS)
- Interceptors
- Pipes for validation
```

## Integration Pattern Detection

### Database Access (TypeORM/Prisma)
```typescript
// TypeORM Repository
@Injectable()
export class CustomerRepository {
    constructor(
        @InjectRepository(Customer)
        private repository: Repository<Customer>
    ) {}
    
    async findActive(): Promise<Customer[]> {
        return this.repository.find({
            where: { status: CustomerStatus.ACTIVE },
            relations: ['orders']
        });
    }
    
    async findByEmail(email: string): Promise<Customer | null> {
        return this.repository.findOne({ where: { email } });
    }
}

// Prisma Client
@Injectable()
export class CustomerService {
    constructor(private prisma: PrismaService) {}
    
    async findAll(): Promise<Customer[]> {
        return this.prisma.customer.findMany({
            include: { orders: true }
        });
    }
    
    async create(data: CreateCustomerDto): Promise<Customer> {
        return this.prisma.customer.create({
            data: {
                name: data.name,
                email: data.email,
                status: CustomerStatus.ACTIVE
            }
        });
    }
}

* Look for:
- Repository pattern (TypeORM)
- PrismaClient methods (Prisma)
- Query builders
- Relations/includes
```

### HTTP Clients (Axios/Fetch)
```typescript
// Axios
import axios from 'axios';

export class PaymentClient {
    private baseURL = process.env.PAYMENT_API_URL;
    
    async processPayment(request: PaymentRequest): Promise<PaymentResponse> {
        const response = await axios.post<PaymentResponse>(
            `${this.baseURL}/payments`,
            request,
            {
                headers: { 'Authorization': `Bearer ${this.apiKey}` },
                timeout: 5000
            }
        );
        return response.data;
    }
}

// Fetch API
async function fetchCustomerData(customerId: string): Promise<Customer> {
    const response = await fetch(`/api/customers/${customerId}`);
    
    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return response.json();
}

* Look for:
- axios HTTP methods
- fetch API calls
- HTTP headers configuration
- Error handling for HTTP errors
```

### Message Queues
```typescript
// RabbitMQ with amqplib
import amqp from 'amqplib';

export class OrderEventPublisher {
    private channel: amqp.Channel;
    
    async publishOrderCreated(order: Order): Promise<void> {
        const message = JSON.stringify({
            type: 'ORDER_CREATED',
            data: order
        });
        
        this.channel.sendToQueue('orders', Buffer.from(message), {
            persistent: true
        });
    }
}

// Bull queue (Redis-based)
import { Queue } from 'bull';

const emailQueue = new Queue('email', {
    redis: { host: 'localhost', port: 6379 }
});

emailQueue.process(async (job) => {
    await sendEmail(job.data.to, job.data.subject, job.data.body);
});

await emailQueue.add({ to: 'user@example.com', subject: 'Welcome', body: 'Hello!' });

* Look for:
- Queue publishing and consuming
- Message formats
- Queue configuration
- Job processing
```

### Caching (Redis)
```typescript
import Redis from 'ioredis';

@Injectable()
export class CacheService {
    private redis: Redis;
    
    constructor() {
        this.redis = new Redis({
            host: process.env.REDIS_HOST,
            port: Number(process.env.REDIS_PORT)
        });
    }
    
    async get<T>(key: string): Promise<T | null> {
        const data = await this.redis.get(key);
        return data ? JSON.parse(data) : null;
    }
    
    async set(key: string, value: any, ttl?: number): Promise<void> {
        const data = JSON.stringify(value);
        if (ttl) {
            await this.redis.setex(key, ttl, data);
        } else {
            await this.redis.set(key, data);
        }
    }
    
    async del(key: string): Promise<void> {
        await this.redis.del(key);
    }
}

* Look for:
- Redis client usage
- Cache get/set operations
- TTL (time-to-live) configuration
- Cache invalidation
```

## Error Handling Patterns

### Try/Catch
```typescript
async function processOrder(orderId: string): Promise<void> {
    try {
        const order = await orderRepository.findById(orderId);
        
        if (!order) {
            throw new NotFoundException(`Order ${orderId} not found`);
        }
        
        await orderService.process(order);
    } catch (error) {
        if (error instanceof NotFoundException) {
            logger.warn(`Order not found: ${orderId}`);
            throw error;
        }
        
        logger.error(`Error processing order: ${error.message}`, error);
        throw new InternalServerErrorException('Order processing failed');
    }
}
```

### Global Exception Filters (NestJS)
```typescript
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
    catch(exception: unknown, host: ArgumentsHost) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse<Response>();
        const request = ctx.getRequest<Request>();
        
        let status = HttpStatus.INTERNAL_SERVER_ERROR;
        let message = 'Internal server error';
        
        if (exception instanceof HttpException) {
            status = exception.getStatus();
            message = exception.message;
        }
        
        response.status(status).json({
            statusCode: status,
            timestamp: new Date().toISOString(),
            path: request.url,
            message
        });
    }
}

* Look for:
- @Catch decorators
- Exception filter implementations
- Custom exception classes
- Error response formatting
```

### Validation (class-validator)
```typescript
import { IsString, IsEmail, MinLength, IsEnum, validateOrReject } from 'class-validator';

export class CreateCustomerDto {
    @IsString()
    @MinLength(2, { message: 'Name must be at least 2 characters' })
    name: string;
    
    @IsEmail({}, { message: 'Invalid email format' })
    email: string;
    
    @IsEnum(CustomerStatus, { message: 'Invalid status' })
    status: CustomerStatus;
}

// Usage
async function createCustomer(data: any): Promise<Customer> {
    const dto = Object.assign(new CreateCustomerDto(), data);
    await validateOrReject(dto);
    return customerService.create(dto);
}

* Look for:
- Validation decorators
- ValidationPipe (NestJS)
- Manual validation with validateOrReject
```

## Configuration Patterns

### Environment Variables
```typescript
// .env file
DATABASE_URL=postgresql://localhost:5432/mydb
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=your-secret-key
API_PORT=3000

// Configuration service
import * as dotenv from 'dotenv';

dotenv.config();

export const config = {
    database: {
        url: process.env.DATABASE_URL,
    },
    redis: {
        host: process.env.REDIS_HOST,
        port: Number(process.env.REDIS_PORT || 6379),
    },
    jwt: {
        secret: process.env.JWT_SECRET || 'default-secret',
        expiresIn: '1h',
    },
    port: Number(process.env.API_PORT || 3000),
};

* Look for:
- .env files
- process.env usage
- ConfigService (NestJS)
- dotenv package
```

### Configuration Files
```typescript
// config/database.config.ts
export default {
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 5432,
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    synchronize: false,
    logging: process.env.NODE_ENV === 'development',
};

* Look for:
- Config directory
- Exported configuration objects
- Environment-specific configs
```

## Testing Patterns

### Jest Unit Tests
```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { CustomerService } from './customer.service';
import { CustomerRepository } from './customer.repository';

describe('CustomerService', () => {
    let service: CustomerService;
    let repository: CustomerRepository;
    
    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                CustomerService,
                {
                    provide: CustomerRepository,
                    useValue: {
                        findById: jest.fn(),
                        create: jest.fn(),
                    },
                },
            ],
        }).compile();
        
        service = module.get<CustomerService>(CustomerService);
        repository = module.get<CustomerRepository>(CustomerRepository);
    });
    
    it('should find customer by id', async () => {
        const mockCustomer = { id: '1', name: 'John Doe' };
        jest.spyOn(repository, 'findById').mockResolvedValue(mockCustomer);
        
        const result = await service.findById('1');
        
        expect(result).toEqual(mockCustomer);
        expect(repository.findById).toHaveBeenCalledWith('1');
    });
});

* Look for:
- describe/it blocks
- beforeEach setup
- jest.fn(), jest.spyOn
- expect assertions
```

### Integration Tests
```typescript
import request from 'supertest';
import { INestApplication } from '@nestjs/common';

describe('CustomerController (e2e)', () => {
    let app: INestApplication;
    
    beforeAll(async () => {
        const moduleFixture = await Test.createTestingModule({
            imports: [AppModule],
        }).compile();
        
        app = moduleFixture.createNestApplication();
        await app.init();
    });
    
    it('/customers (POST)', () => {
        return request(app.getHttpServer())
            .post('/customers')
            .send({ name: 'John Doe', email: 'john@example.com' })
            .expect(201)
            .expect((res) => {
                expect(res.body.name).toBe('John Doe');
            });
    });
    
    afterAll(async () => {
        await app.close();
    });
});

* Look for:
- supertest for HTTP testing
- E2E test files (*e2e-spec.ts)
- Full application bootstrap
- HTTP request testing
```

## Best Practices for Discovery

1. **Start with package.json** - Identify framework (Express, NestJS, Next.js)
2. **Find main entry point** - index.ts, main.ts, server.ts
3. **Map API routes** - Controllers, routers, endpoints
4. **Trace service layer** - Business logic and orchestration
5. **Identify data access** - Repositories, Prisma, TypeORM, Mongoose
6. **Document integrations** - HTTP clients, queues, caching
7. **Extract business rules** - From service methods
8. **Note async patterns** - Promises, async/await, event emitters
9. **Map authentication** - Guards, middleware, JWT
10. **Document configuration** - Environment variables, config files

## Output Format

When documenting TypeScript/JavaScript flows:

```markdown
## Flow: [Flow Name]
- **Entry Point**: POST /api/orders (OrderController.createOrder)
- **Framework**: NestJS / Express
- **Layer Flow**: Controller → Service → Repository
- **Input**: CreateOrderDto (customerId, productId, quantity)
- **Processing**:
  1. Controller receives request
  2. Validates DTO
  3. Calls OrderService.create()
  4. Service validates customer exists
  5. Checks inventory stock
  6. Calculates total price
  7. Creates order in database
  8. Publishes order.created event
- **Output**: OrderDto with order details
- **Integration**:
  - Database: PostgreSQL via TypeORM
  - Cache: Redis for customer data
  - Queue: RabbitMQ for events
- **Error Handling**:
  - 404 if customer not found
  - 400 if insufficient stock
  - 500 for system errors
- **Async**: Uses async/await, Promise.all for parallel operations
- **Transaction**: Database transaction via TypeORM
- **Dependencies**:
  - Services: OrderService, CustomerService, InventoryService
  - Repositories: OrderRepository
  - DTOs: CreateOrderDto, OrderDto
```

This skill enables comprehensive documentation of TypeScript/JavaScript applications across various frameworks and architectures.
