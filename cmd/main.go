package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"

	_ "github.com/lib/pq"
)

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Error: connection string or query not provided")
		os.Exit(1)
	}

	connStr := os.Args[1]
	query := os.Args[2]

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("Error connecting to the database: %v", err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		log.Fatalf("Unable to connect to the database: %v", err)
	}

	rows, err := db.Query(query)
	if err != nil {
		log.Fatalf("Error executing the query: %v", err)
	}
	defer rows.Close()

	columns, err := rows.Columns()
	if err != nil {
		log.Fatalf("Error retrieving columns: %v", err)
	}

	colWidths := make([]int, len(columns))
	for i, col := range columns {
		colWidths[i] = len(col)
	}

	var allRows [][]string
	for rows.Next() {
		rowData := make([]sql.NullString, len(columns))
		scanArgs := make([]interface{}, len(columns))
		for i := range rowData {
			scanArgs[i] = &rowData[i]
		}

		err = rows.Scan(scanArgs...)
		if err != nil {
			log.Fatalf("Error scanning row: %v", err)
		}

		row := make([]string, len(columns))
		for i, col := range rowData {
			row[i] = col.String
			if len(row[i]) > colWidths[i] {
				colWidths[i] = len(row[i])
			}
		}
		allRows = append(allRows, row)
	}

	var sb strings.Builder
	format := make([]string, len(columns))
	for i, width := range colWidths {
		format[i] = fmt.Sprintf("%%-%ds", width)
	}

	for i, col := range columns {
		if i > 0 {
			sb.WriteString(" | ")
		}
		sb.WriteString(fmt.Sprintf(format[i], col))
	}
	sb.WriteString("\n")
	sb.WriteString(strings.Repeat("-", sb.Len()-1))
	sb.WriteString("\n")

	for _, row := range allRows {
		for i, col := range row {
			if i > 0 {
				sb.WriteString(" | ")
			}
			sb.WriteString(fmt.Sprintf(format[i], col))
		}
		sb.WriteString("\n")
	}

	fmt.Println(sb.String())

	if err = rows.Err(); err != nil {
		log.Fatalf("Error processing rows: %v", err)
	}
}
