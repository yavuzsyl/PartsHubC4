# PartsHub Marketplace – C4 Model

This repository contains a complete **C4 model** of **PartsHub**, a B2B marketplace that connects car‑part sellers with buyers such as garages and repair shops. The model is authored in [Structurizr DSL](https://docs.structurizr.com/dsl) and can be rendered locally or in the cloud.

---

## Repository Structure

| Path                       | Description                                                                                                        |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `partshub-marketplace.dsl` | Main Structurizr DSL workspace (System Context, Container, Component diagrams, plus a placeholder Code‑level view) |
| `README.md`                | You are here – usage instructions & project overview                                                               |

> **Heads‑up :** If you’re new to C4, check out [https://c4model.com](https://c4model.com) for a 5‑minute primer.

---

---

## Diagrams Included

1. **System Context Diagram** – how PartsHub fits into its environment (buyers, sellers, external services like Auth0, Stripe, etc.)
2. **Container Diagram** – high‑level technology breakdown (React SPA, ASP.NET API, Worker, SQL, Elasticsearch, RabbitMQ)
3. **Component Diagram** – key ASP.NET controllers & services inside the API container
4. **Code Diagram (placeholder)** – hook for sequence/class diagrams when needed

> External services (Auth0, Stripe, Sendinblue, Shipping) are visually differentiated in gray via the `ExternalSystem` tag.


## License

```
MIT © 2025 PartsHub Contributors
```
