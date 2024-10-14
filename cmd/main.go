package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

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

	results := make([][]byte, len(columns))
	scanArgs := make([]interface{}, len(columns))
	for i := range results {
		scanArgs[i] = &results[i]
	}

	for rows.Next() {
		err = rows.Scan(scanArgs...)
		if err != nil {
			log.Fatalf("Error scanning row: %v", err)
		}

		var result string
		for i, col := range results {
			if i > 0 {
				result += " | "
			}
			result += string(col)
		}
		fmt.Println(result)
	}

	if err = rows.Err(); err != nil {
		log.Fatalf("Error processing rows: %v", err)
	}
}
