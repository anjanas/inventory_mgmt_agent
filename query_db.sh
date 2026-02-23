#!/bin/bash

# Database query script for Munder Difflin inventory management system
# Usage: ./query_db.sh [table] [options]

DB_FILE="munder_difflin.db"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if database exists
if [ ! -f "$DB_FILE" ]; then
    echo -e "${RED}Error: Database file '$DB_FILE' not found!${NC}"
    echo "Please run project_starter.py first to initialize the database."
    exit 1
fi

# Function to display help
show_help() {
    echo -e "${BLUE}Munder Difflin Database Query Tool${NC}"
    echo ""
    echo "Usage: $0 [table] [options]"
    echo ""
    echo "Tables:"
    echo "  transactions    - Query transaction records"
    echo "  quotes         - Query historical quotes"
    echo "  quote_requests - Query customer quote requests"
    echo "  inventory      - Query inventory items"
    echo ""
    echo "Options:"
    echo "  --all          - Show all records (default)"
    echo "  --limit N      - Limit results to N rows"
    echo "  --count        - Show count of records"
    echo "  --summary      - Show summary statistics"
    echo "  --help         - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 transactions --limit 10"
    echo "  $0 quotes --summary"
    echo "  $0 inventory --all"
    echo "  $0 transactions --count"
}

# Function to query transactions
query_transactions() {
    local limit=$1
    local count=$2
    local summary=$3
    
    if [ "$count" = true ]; then
        echo -e "${GREEN}Transaction Count:${NC}"
        sqlite3 "$DB_FILE" "SELECT COUNT(*) as total_transactions FROM transactions;"
        return
    fi
    
    if [ "$summary" = true ]; then
        echo -e "${GREEN}Transaction Summary:${NC}"
        echo ""
        echo -e "${YELLOW}Total Transactions:${NC}"
        sqlite3 -header -column "$DB_FILE" "SELECT COUNT(*) as total FROM transactions;"
        echo ""
        echo -e "${YELLOW}By Type:${NC}"
        sqlite3 -header -column "$DB_FILE" "
            SELECT transaction_type, COUNT(*) as count, 
                   SUM(price) as total_value,
                   SUM(units) as total_units
            FROM transactions 
            WHERE transaction_type IS NOT NULL
            GROUP BY transaction_type;"
        echo ""
        echo -e "${YELLOW}Recent Transactions (last 10):${NC}"
        sqlite3 -header -column "$DB_FILE" "
            SELECT id, item_name, transaction_type, units, 
                   printf('$%.2f', price) as price, 
                   transaction_date
            FROM transactions 
            ORDER BY transaction_date DESC, id DESC 
            LIMIT 10;"
        return
    fi
    
    echo -e "${GREEN}Transactions:${NC}"
    if [ -n "$limit" ]; then
        sqlite3 -header -column "$DB_FILE" "
            SELECT id, item_name, transaction_type, units, 
                   printf('$%.2f', price) as price, 
                   transaction_date
            FROM transactions 
            ORDER BY transaction_date DESC, id DESC 
            LIMIT $limit;"
    else
        sqlite3 -header -column "$DB_FILE" "
            SELECT id, item_name, transaction_type, units, 
                   printf('$%.2f', price) as price, 
                   transaction_date
            FROM transactions 
            ORDER BY transaction_date DESC, id DESC;"
    fi
}

# Function to query quotes
query_quotes() {
    local limit=$1
    local count=$2
    local summary=$3
    
    if [ "$count" = true ]; then
        echo -e "${GREEN}Quote Count:${NC}"
        sqlite3 "$DB_FILE" "SELECT COUNT(*) as total_quotes FROM quotes;"
        return
    fi
    
    if [ "$summary" = true ]; then
        echo -e "${GREEN}Quotes Summary:${NC}"
        echo ""
        echo -e "${YELLOW}Total Quotes:${NC}"
        sqlite3 -header -column "$DB_FILE" "SELECT COUNT(*) as total FROM quotes;"
        echo ""
        echo -e "${YELLOW}By Order Size:${NC}"
        sqlite3 -header -column "$DB_FILE" "
            SELECT order_size, COUNT(*) as count, 
                   AVG(total_amount) as avg_amount,
                   SUM(total_amount) as total_value
            FROM quotes 
            WHERE order_size IS NOT NULL AND order_size != ''
            GROUP BY order_size;"
        echo ""
        echo -e "${YELLOW}By Event Type:${NC}"
        sqlite3 -header -column "$DB_FILE" "
            SELECT event_type, COUNT(*) as count, 
                   AVG(total_amount) as avg_amount
            FROM quotes 
            WHERE event_type IS NOT NULL AND event_type != ''
            GROUP BY event_type;"
        echo ""
        echo -e "${YELLOW}Top 5 Quotes by Amount:${NC}"
        sqlite3 -header -column "$DB_FILE" "
            SELECT request_id, 
                   printf('$%.2f', total_amount) as amount,
                   job_type, order_size, event_type, order_date
            FROM quotes 
            ORDER BY total_amount DESC 
            LIMIT 5;"
        return
    fi
    
    echo -e "${GREEN}Quotes:${NC}"
    if [ -n "$limit" ]; then
        sqlite3 -header -column "$DB_FILE" "
            SELECT request_id, 
                   printf('$%.2f', total_amount) as total_amount,
                   job_type, order_size, event_type, order_date
            FROM quotes 
            ORDER BY order_date DESC, request_id DESC 
            LIMIT $limit;"
    else
        sqlite3 -header -column "$DB_FILE" "
            SELECT request_id, 
                   printf('$%.2f', total_amount) as total_amount,
                   job_type, order_size, event_type, order_date
            FROM quotes 
            ORDER BY order_date DESC, request_id DESC;"
    fi
}

# Function to query quote_requests
query_quote_requests() {
    local limit=$1
    local count=$2
    local summary=$3
    
    if [ "$count" = true ]; then
        echo -e "${GREEN}Quote Request Count:${NC}"
        sqlite3 "$DB_FILE" "SELECT COUNT(*) as total_requests FROM quote_requests;"
        return
    fi
    
    if [ "$summary" = true ]; then
        echo -e "${GREEN}Quote Requests Summary:${NC}"
        echo ""
        echo -e "${YELLOW}Total Requests:${NC}"
        sqlite3 -header -column "$DB_FILE" "SELECT COUNT(*) as total FROM quote_requests;"
        echo ""
        echo -e "${YELLOW}Sample Requests (first 5):${NC}"
        sqlite3 -header -column "$DB_FILE" "
            SELECT id, 
                   substr(response, 1, 100) || '...' as request_preview
            FROM quote_requests 
            LIMIT 5;"
        return
    fi
    
    echo -e "${GREEN}Quote Requests:${NC}"
    if [ -n "$limit" ]; then
        sqlite3 -header -column "$DB_FILE" "
            SELECT id, 
                   substr(response, 1, 150) || '...' as request_preview
            FROM quote_requests 
            ORDER BY id 
            LIMIT $limit;"
    else
        sqlite3 -header -column "$DB_FILE" "
            SELECT id, 
                   substr(response, 1, 150) || '...' as request_preview
            FROM quote_requests 
            ORDER BY id;"
    fi
}

# Function to query inventory
query_inventory() {
    local limit=$1
    local count=$2
    local summary=$3
    
    if [ "$count" = true ]; then
        echo -e "${GREEN}Inventory Item Count:${NC}"
        sqlite3 "$DB_FILE" "SELECT COUNT(*) as total_items FROM inventory;"
        return
    fi
    
    if [ "$summary" = true ]; then
        echo -e "${GREEN}Inventory Summary:${NC}"
        echo ""
        echo -e "${YELLOW}Total Items:${NC}"
        sqlite3 -header -column "$DB_FILE" "SELECT COUNT(*) as total FROM inventory;"
        echo ""
        echo -e "${YELLOW}By Category:${NC}"
        sqlite3 -header -column "$DB_FILE" "
            SELECT category, COUNT(*) as item_count,
                   SUM(current_stock) as total_stock,
                   printf('$%.2f', SUM(current_stock * unit_price)) as total_value
            FROM inventory 
            GROUP BY category;"
        echo ""
        echo -e "${YELLOW}Low Stock Items (below min_stock_level):${NC}"
        sqlite3 -header -column "$DB_FILE" "
            SELECT item_name, category, current_stock, min_stock_level,
                   printf('$%.2f', unit_price) as unit_price
            FROM inventory 
            WHERE current_stock < min_stock_level
            ORDER BY (current_stock - min_stock_level) ASC;"
        echo ""
        echo -e "${YELLOW}Top 10 Items by Stock Value:${NC}"
        sqlite3 -header -column "$DB_FILE" "
            SELECT item_name, category, current_stock,
                   printf('$%.2f', unit_price) as unit_price,
                   printf('$%.2f', current_stock * unit_price) as total_value
            FROM inventory 
            ORDER BY (current_stock * unit_price) DESC 
            LIMIT 10;"
        return
    fi
    
    echo -e "${GREEN}Inventory:${NC}"
    if [ -n "$limit" ]; then
        sqlite3 -header -column "$DB_FILE" "
            SELECT item_name, category, 
                   printf('$%.2f', unit_price) as unit_price,
                   current_stock, min_stock_level
            FROM inventory 
            ORDER BY item_name 
            LIMIT $limit;"
    else
        sqlite3 -header -column "$DB_FILE" "
            SELECT item_name, category, 
                   printf('$%.2f', unit_price) as unit_price,
                   current_stock, min_stock_level
            FROM inventory 
            ORDER BY item_name;"
    fi
}

# Function to show financial summary
show_financial_summary() {
    echo -e "${GREEN}Financial Summary:${NC}"
    echo ""
    
    echo -e "${YELLOW}Cash Balance (from transactions):${NC}"
    sqlite3 -header -column "$DB_FILE" "
        SELECT 
            printf('$%.2f', 
                COALESCE(SUM(CASE WHEN transaction_type = 'sales' THEN price ELSE 0 END), 0) -
                COALESCE(SUM(CASE WHEN transaction_type = 'stock_orders' THEN price ELSE 0 END), 0)
            ) as cash_balance
        FROM transactions;"
    
    echo ""
    echo -e "${YELLOW}Total Sales Revenue:${NC}"
    sqlite3 -header -column "$DB_FILE" "
        SELECT 
            COUNT(*) as transaction_count,
            printf('$%.2f', SUM(price)) as total_revenue,
            SUM(units) as total_units_sold
        FROM transactions 
        WHERE transaction_type = 'sales' AND item_name IS NOT NULL;"
    
    echo ""
    echo -e "${YELLOW}Total Stock Purchases:${NC}"
    sqlite3 -header -column "$DB_FILE" "
        SELECT 
            COUNT(*) as transaction_count,
            printf('$%.2f', SUM(price)) as total_cost,
            SUM(units) as total_units_purchased
        FROM transactions 
        WHERE transaction_type = 'stock_orders';"
    
    echo ""
    echo -e "${YELLOW}Inventory Value:${NC}"
    sqlite3 -header -column "$DB_FILE" "
        SELECT 
            COUNT(*) as item_count,
            SUM(current_stock) as total_units,
            printf('$%.2f', SUM(current_stock * unit_price)) as total_value
        FROM inventory;"
}

# Parse arguments
TABLE=""
LIMIT=""
COUNT=false
SUMMARY=false
FINANCIAL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        transactions|quotes|quote_requests|inventory)
            TABLE=$1
            shift
            ;;
        --limit)
            LIMIT=$2
            shift 2
            ;;
        --count)
            COUNT=true
            shift
            ;;
        --summary)
            SUMMARY=true
            shift
            ;;
        --financial)
            FINANCIAL=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Show financial summary if requested
if [ "$FINANCIAL" = true ]; then
    show_financial_summary
    exit 0
fi

# If no table specified, show all tables summary
if [ -z "$TABLE" ]; then
    echo -e "${BLUE}=== Database Overview ===${NC}"
    echo ""
    echo -e "${YELLOW}Table Counts:${NC}"
    sqlite3 -header -column "$DB_FILE" "
        SELECT 'transactions' as table_name, COUNT(*) as count FROM transactions
        UNION ALL
        SELECT 'quotes', COUNT(*) FROM quotes
        UNION ALL
        SELECT 'quote_requests', COUNT(*) FROM quote_requests
        UNION ALL
        SELECT 'inventory', COUNT(*) FROM inventory;"
    echo ""
    echo "Use --help for query options"
    exit 0
fi

# Execute appropriate query function
case $TABLE in
    transactions)
        query_transactions "$LIMIT" "$COUNT" "$SUMMARY"
        ;;
    quotes)
        query_quotes "$LIMIT" "$COUNT" "$SUMMARY"
        ;;
    quote_requests)
        query_quote_requests "$LIMIT" "$COUNT" "$SUMMARY"
        ;;
    inventory)
        query_inventory "$LIMIT" "$COUNT" "$SUMMARY"
        ;;
    *)
        echo -e "${RED}Unknown table: $TABLE${NC}"
        show_help
        exit 1
        ;;
esac
