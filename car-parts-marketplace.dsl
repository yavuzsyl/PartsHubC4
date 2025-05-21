workspace "PartsHub Marketplace" "C4 model diagrams for PartsHub — a  marketplace that connects car‑part sellers with buyers such as garages or repair shops." {

    model {
        # PEOPLE
        buyer   = person "Buyer"   "A garage/repair‑shop owner who purchases car parts from the marketplace." "Customer"
        seller  = person "Seller"  "A business that lists and sells car parts via the marketplace." "Customer"
        support = person "Customer Support" "Marketplace support team handling enquiries from buyers and sellers." "Staff"

        # CORE SOFTWARE SYSTEM AND CONTAINERS
        group "PartsHub" {
            marketplace = softwareSystem "PartsHub Marketplace" "Enables sellers to list parts and buyers to search, purchase and arrange shipping." {

                # Front‑end delivery
                web = container "Web Application" "Delivers static assets (HTML, JS, CSS) and serves the SPA to end‑users." "Nginx"
                spa = container "Single‑Page Application" "Client‑side React app that renders the marketplace UI and interacts with the API via JSON/HTTPS." "React"

                # API + internal components
                api = container "API Application" "Core back‑end implementing business logic and exposing JSON/HTTPS endpoints." "ASP.NET 8" {
                    productsController   = component "Products Controller"   "Exposes CRUD endpoints for catalog products and inventory operations." "ASP.NET Controller"
                    categoriesController = component "Categories Controller" "Manages hierarchical category data, providing create/read/update operations for the category tree used by search and navigation." "ASP.NET Controller"
                    basketController     = component "Basket Controller"     "Maintains the buyer’s shopping basket, allowing add/remove/update of items and computing totals prior to checkout." "ASP.NET Controller"
                    paymentsController   = component "Payments Controller"   "Coordinates the checkout flow: creates Stripe payment intents, records orders, and handles webhook callbacks for payment success or failure." "ASP.NET Controller"

                    searchService  = component "Search Service"  "Encapsulates Elasticsearch indexing and query logic, mapping domain objects to search documents." "C# Service"
                    paymentService = component "Payment Service" "Wraps the Stripe SDK for creating, capturing, and refunding payments, and publishes payment events to the message broker." "C# Service"
                    emailService   = component "Email Service"   "Sends transactional emails such as order confirmations and password resets via the Sendinblue API." "C# Service"
                    repository     = component "Repository Layer" "Provides data‑access abstractions (via Entity Framework Core) for MSSQL, used by controllers and services." "C# Library"
                }

                # Async processing
                group "Async Processing" {
                    bus = container "Message Broker" "RabbitMQ cluster enabling asynchronous, reliable event distribution between services." "RabbitMQ"
                    wrk = container "Worker Application" "Background worker that consumes messages (indexing, e‑mail, payment events)." ".NET Console"
                }

                # Data stores & observability
                group "Data Stores" {
                    db  = container "SQL Database" "Relational store for products, orders, users, and inventory." "Microsoft SQL Server"
                    es  = container "Search Cluster" "Elasticsearch cluster providing full‑text and faceted search." "Elasticsearch"
                    log = container "Log Aggregator" "Centralised log collection and dashboards for troubleshooting and alerts." "Graylog"
                }
            }
        }

        # EXTERNAL SERVICES
        group "External Services" {
            auth0       = softwareSystem "Auth0"              "OAuth2/OIDC identity provider."           "ExternalSystem"
            stripe      = softwareSystem "Stripe"             "Payment processing & payouts."            "ExternalSystem"
            sendinblue  = softwareSystem "Sendinblue"         "Transactional e‑mail delivery."          "ExternalSystem"
            shippingAPI = softwareSystem "Shipping Companies" "Label creation & tracking APIs."          "ExternalSystem"
        }

        # RELATIONSHIPS – PEOPLE → SYSTEM
        buyer  -> spa "Shops for parts, places orders"
        seller -> spa "Manages catalogue & orders"
        support -> api "Uses admin endpoints"

        # RELATIONSHIPS – CONTAINERS
        spa  -> api "REST/JSON" "HTTPS"
        web  -> spa "Delivers React SPA"

        api  -> db  "Reads/writes" "TDS/TCP"
        api  -> es  "Indexes & queries" "HTTP"
        api  -> bus "Publishes domain events" "AMQP"
        api  -> stripe     "Payment intents & webhooks" "HTTPS"
        api  -> auth0      "Authentication & JWT validation" "OIDC"
        api  -> sendinblue "Transactional e‑mails" "HTTPS"
        api  -> shippingAPI "Create labels & track" "HTTPS"
        api  -> log "Structured logs"

        wrk  -> bus        "Consumes events" "AMQP"
        wrk  -> es         "Indexes product data" "HTTP"
        wrk  -> sendinblue "Sends e‑mails" "HTTPS"
        wrk  -> stripe     "Processes payment webhooks" "HTTPS"
        wrk  -> log        "Structured logs"

        web  -> log        "Access logs"

        # COMPONENT RELATIONSHIPS (API container)
        spa -> productsController   "CRUD parts" "JSON/HTTPS"
        spa -> categoriesController "Read categories" "JSON/HTTPS"
        spa -> basketController     "Basket ops" "JSON/HTTPS"
        spa -> paymentsController   "Checkout" "JSON/HTTPS"

        productsController   -> repository     "SQL access"
        categoriesController -> repository
        basketController     -> repository
        paymentsController   -> repository

        productsController   -> searchService  "Index/query"
        searchService        -> es            "REST"

        paymentsController   -> paymentService "Create payment"
        paymentService       -> stripe         "HTTPS"
        paymentService       -> bus            "Payment events"

        paymentsController   -> emailService   "Confirmation e‑mail"
        emailService         -> sendinblue     "HTTPS"

        repository           -> db             "TDS/TCP"
    }

    views {
        # System Context – high‑level relationships
        systemcontext marketplace "SystemContext" {
            include *
            autoLayout
            description "How PartsHub interacts with buyers, sellers and external services."
        }

        # Container Diagram – shows all containers grouped
        container marketplace "Containers" {
            include web
            include spa
            include api
            include bus
            include wrk
            include db
            include es
            include log
            include auth0
            include stripe
            include sendinblue
            include shippingAPI
            autoLayout
            description "All containers that make up the PartsHub Marketplace, plus external services."
        }

        # Component Diagram – API container internals
        component api "Components" {
            include productsController
            include categoriesController
            include basketController
            include paymentsController
            include searchService
            include paymentService
            include emailService
            include repository
            include spa
            include bus
            include es
            include stripe
            include sendinblue
            include db
            autoLayout
            description "Component diagram for the ASP.NET API – shows controllers at the top, domain services in the middle, and infrastructure at the bottom, similar to the example layout."
            animation {
                spa productsController categoriesController basketController paymentsController
                repository searchService paymentService emailService
                db es stripe sendinblue bus
            }
        }

        # Styling
        styles {
            element "Person" {
                shape Person
                color #ffffff
                fontSize 22
            }
            element "Customer" {
                background #0B60A9
            }
            element "Staff" {
                background #999999
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "ExternalSystem" {
                background #9E9E9E
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
        }        }
    }
}
