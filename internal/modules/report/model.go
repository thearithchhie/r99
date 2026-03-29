package report

// SalesReport represents a detailed sales report
type SalesReport struct {
	StartDate     string  `json:"start_date"`
	EndDate       string  `json:"end_date"`
	TotalSales    int     `json:"total_sales"`
	TotalRevenue  float64 `json:"total_revenue"`
	TotalTax      float64 `json:"total_tax"`
	TotalDiscount float64 `json:"total_discount"`
	AverageOrder  float64 `json:"average_order"`
}

// InventoryReport represents an inventory report
type InventoryReport struct {
	TotalProducts     int     `json:"total_products"`
	TotalValue        float64 `json:"total_value"`
	LowStockItems     int     `json:"low_stock_items"`
	OutOfStockItems   int     `json:"out_of_stock_items"`
}

// CustomerReport represents a customer report
type CustomerReport struct {
	TotalCustomers   int     `json:"total_customers"`
	ActiveCustomers  int     `json:"active_customers"`
	TotalPurchases   int     `json:"total_purchases"`
	AverageSpending  float64 `json:"average_spending"`
}

// TopProduct represents a top selling product
type TopProduct struct {
	ProductID   int     `json:"product_id"`
	ProductName string  `json:"product_name"`
	TotalSold   int     `json:"total_sold"`
	Revenue     float64 `json:"revenue"`
}

// ProductSalesReport represents product sales report
type ProductSalesReport struct {
	StartDate  string       `json:"start_date"`
	EndDate    string       `json:"end_date"`
	TopProducts []TopProduct `json:"top_products"`
}

// RevenueByPaymentMethod represents revenue breakdown by payment method
type RevenueByPaymentMethod struct {
	PaymentMethod string  `json:"payment_method"`
	TotalRevenue  float64 `json:"total_revenue"`
	Count         int     `json:"count"`
}

// PaymentReport represents payment methods report
type PaymentReport struct {
	StartDate        string                    `json:"start_date"`
	EndDate          string                    `json:"end_date"`
	PaymentMethods   []RevenueByPaymentMethod  `json:"payment_methods"`
}

// DailySale represents daily sales data
type DailySale struct {
	Date        string  `json:"date"`
	TotalSales  int     `json:"total_sales"`
	Revenue     float64 `json:"revenue"`
}

// DailySalesReport represents daily sales report
type DailySalesReport struct {
	StartDate string       `json:"start_date"`
	EndDate   string       `json:"end_date"`
	DailyData []DailySale  `json:"daily_data"`
}
