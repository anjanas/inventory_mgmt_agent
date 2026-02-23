# Inventory Management Agent System

A multi-agent AI system for automated inventory management, quote generation, and order processing for a paper supply company (Munder Difflin). This project demonstrates the use of specialized AI agents working together to handle complex business workflows.

## Overview

This system uses **Pydantic AI** to create a multi-agent architecture where specialized agents coordinate to:
- Check inventory levels
- Search historical quotes
- Generate quotes for customers
- Process orders and manage transactions
- Track financial state (cash balance, inventory value)

## Features

- **Multi-Agent Architecture**: Four specialized agents working in coordination
- **Date-Aware Inventory Tracking**: Stock levels calculated as of specific dates
- **Financial Management**: Automatic tracking of cash balance and inventory valuation
- **Historical Quote Search**: Search past quotes to inform pricing decisions
- **Transaction Logging**: Complete audit trail of all stock orders and sales
- **Delivery Date Estimation**: Automatic calculation of supplier delivery dates based on order size

## Architecture

### Agents

1. **Inventory Agent**
   - Checks stock levels for specific items
   - Provides comprehensive inventory information
   - Determines item availability for orders
   - Tools: `check_stock_level`, `get_all_inventory_items`

2. **Quoting Agent**
   - Searches historical quotes for similar past orders
   - Helps generate accurate quotes based on historical data
   - Analyzes quote patterns and pricing trends
   - Tools: `search_historical_quotes`

3. **Ordering Agent**
   - Creates transactions for stock orders and sales
   - Checks cash balance before purchases
   - Calculates delivery dates for orders
   - Ensures sufficient funds before ordering
   - Tools: `create_order_transaction`, `get_cash_balance_info`, `check_delivery_date`

4. **Orchestration Agent**
   - Coordinates all specialized agents
   - Routes requests to appropriate agents
   - Manages multi-step workflows
   - Synthesizes results into comprehensive responses
   - Has access to all tools for coordination

### Database Schema

The system uses SQLite with the following tables:

- **`transactions`**: Logs all stock orders and sales
- **`quote_requests`**: Customer quote requests
- **`quotes`**: Historical quotes with metadata
- **`inventory`**: Reference table of all inventory items

## Setup

### Prerequisites

- Python 3.9 or higher
- OpenAI API key

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd inventory-mgmt-agent
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Create a `.env` file in the project root:
```bash
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4o  # Optional, defaults to gpt-4.1-nano
```

### Required Files

The system expects the following CSV files:
- `quote_requests.csv`: Historical customer quote requests
- `quotes.csv`: Historical quotes with metadata
- `quote_requests_sample.csv`: Sample requests for testing

## Usage

### Running the Test Scenarios

The main script processes customer requests from `quote_requests_sample.csv`:

```bash
python3 project_starter.py
```

This will:
1. Initialize the database with inventory and historical data
2. Process each customer request chronologically
3. Update financial state after each request
4. Generate a final financial report
5. Save results to `test_results.csv`

### Programmatic Usage

You can also use the agents programmatically:

```python
import asyncio
from project_starter import orchestration_agent, inventory_agent, quoting_agent, ordering_agent

async def example():
    # Use orchestration agent for complex requests
    result = await orchestration_agent.run(
        "I need 500 sheets of A4 paper and 200 sheets of cardstock. Date: 2025-04-15"
    )
    print(result.output)
    
    # Or use specialized agents directly
    inventory_result = await inventory_agent.run(
        "Check stock for A4 paper as of 2025-04-15"
    )
    print(inventory_result.output)

asyncio.run(example())
```

### Database Query Tool

A shell script is provided to easily query the database tables:

```bash
# Show overview of all tables
./query_db.sh

# Query specific tables
./query_db.sh transactions --limit 10
./query_db.sh quotes --summary
./query_db.sh inventory --all
./query_db.sh quote_requests --count

# Show financial summary
./query_db.sh --financial

# Get help
./query_db.sh --help
```

Available options:
- `--all`: Show all records (default)
- `--limit N`: Limit results to N rows
- `--count`: Show count of records
- `--summary`: Show summary statistics
- `--financial`: Show financial summary (cash, revenue, inventory value)

## Project Structure

```
inventory-mgmt-agent/
├── project_starter.py          # Main script with agents and utilities
├── query_db.sh                # Shell script to query database tables
├── requirements.txt           # Python dependencies
├── .env                        # Environment variables (create this)
├── munder_difflin.db          # SQLite database (created on first run)
├── quote_requests.csv         # Historical quote requests
├── quotes.csv                 # Historical quotes
├── quote_requests_sample.csv  # Sample requests for testing
└── test_results.csv           # Test output (generated after run)
```

## Key Components

### Database Functions

- `init_database()`: Sets up database tables and initial data
- `create_transaction()`: Records stock orders or sales
- `get_all_inventory()`: Gets inventory snapshot as of a date
- `get_stock_level()`: Gets stock level for a specific item
- `get_cash_balance()`: Calculates cash balance as of a date
- `generate_financial_report()`: Generates comprehensive financial report
- `search_quote_history()`: Searches historical quotes by keywords

### Tools

All tools are wrapped with Pydantic models for type safety:
- `CheckStockInput/StockLevelOutput`
- `GetAllInventoryInput/InventoryOutput`
- `SearchQuotesInput/SearchQuotesOutput`
- `CreateTransactionInput/TransactionOutput`
- `CashBalanceInput/CashBalanceOutput`
- `DeliveryDateInput/DeliveryDateOutput`

## Inventory Items

The system manages 75+ paper products across categories:
- **Paper Types**: A4, Letter-sized, Cardstock, Colored paper, Glossy paper, etc.
- **Products**: Paper plates, cups, napkins, envelopes, sticky notes, etc.
- **Large-format**: Large poster paper, banner paper rolls
- **Specialty**: Cover stock, text paper, cardstock variants

Each item has:
- Item name
- Category
- Unit price
- Current stock level
- Minimum stock level

## Financial Tracking

The system tracks:
- **Cash Balance**: Total sales revenue minus stock purchase costs
- **Inventory Value**: Total value of all stock on hand
- **Total Assets**: Cash + Inventory Value
- **Top Selling Products**: Best performers by revenue

## Delivery Date Estimation

Delivery lead times based on order quantity:
- ≤10 units: Same day
- 11-100 units: 1 day
- 101-1000 units: 4 days
- >1000 units: 7 days

## Testing

The test system processes requests from `quote_requests_sample.csv` in chronological order, maintaining state between requests. Each request includes:
- Job type (office manager, hotel manager, etc.)
- Event type (ceremony, parade, conference, etc.)
- Order size (small, medium, large)
- Specific item requests
- Delivery date requirements

## Output

After running tests, you'll get:
- Console output showing each request and response
- Financial state updates after each request
- `test_results.csv` with all request/response pairs and financial metrics
- Final financial report summary

## Dependencies

- `pandas==2.2.3`: Data manipulation
- `openai==1.76.0`: OpenAI API client
- `pydantic-ai`: Multi-agent framework
- `SQLAlchemy==2.0.40`: Database ORM
- `python-dotenv==1.1.0`: Environment variable management
- `numpy`: Numerical operations (for inventory generation)

## Notes

- The system uses a default model name from environment or falls back to `gpt-4.1-nano`
- All dates should be in ISO format (YYYY-MM-DD)
- The database is initialized with a starting cash balance of $50,000
- Inventory is randomly generated (40% coverage) with reproducible seed
- Transaction types must be either `'stock_orders'` or `'sales'`

## License

This project is part of a Udacity course on Agentic AI systems.

## Contributing

This is a learning project. Feel free to experiment and extend the functionality!
