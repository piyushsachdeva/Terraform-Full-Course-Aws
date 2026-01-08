package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Goal represents a goal item in our application
type Goal struct {
	ID   int    `json:"ID"`
	Name string `json:"Name"`
}

// Define Prometheus metrics
var (
	addGoalCounter = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "add_goal_requests_total",
		Help: "Total number of add goal requests",
	})
	removeGoalCounter = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "remove_goal_requests_total",
		Help: "Total number of remove goal requests",
	})
	httpRequestsCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"path"},
	)
)

func init() {
	// Register Prometheus metrics
	prometheus.MustRegister(addGoalCounter)
	prometheus.MustRegister(removeGoalCounter)
	prometheus.MustRegister(httpRequestsCounter)
}

func createConnection() (*sql.DB, error) {
	connStr := fmt.Sprintf("user=%s password=%s host=%s port=%s dbname=%s sslmode=%s",
		os.Getenv("DB_USERNAME"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_NAME"),
		os.Getenv("SSL"),
	)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, err
	}

	err = db.Ping()
	if err != nil {
		return nil, err
	}

	// Create goals table if it doesn't exist
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS goals (
		id SERIAL PRIMARY KEY,
		goal_name VARCHAR(255) NOT NULL
	)`)
	if err != nil {
		return nil, fmt.Errorf("error creating goals table: %v", err)
	}

	return db, nil
}

func main() {
	router := gin.Default()

	// Configure CORS to allow requests from frontend
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"http://localhost:3000", "http://frontend:3000"}
	config.AllowMethods = []string{"GET", "POST", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Accept"}
	router.Use(cors.New(config))

	// Connect to PostgreSQL database
	db, err := createConnection()
	if err != nil {
		log.Println("Error connecting to PostgreSQL", err)
		return
	}
	defer db.Close()

	// API Routes
	router.GET("/goals", func(c *gin.Context) {
		// Track API request
		httpRequestsCounter.WithLabelValues("/goals").Inc()

		// Get all goals from database
		rows, err := db.Query("SELECT id, goal_name FROM goals")
		if err != nil {
			log.Println("Error querying database", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   "Error querying the database",
			})
			return
		}
		defer rows.Close()

		var goals []Goal
		for rows.Next() {
			var goal Goal
			if err := rows.Scan(&goal.ID, &goal.Name); err != nil {
				log.Println("Error scanning row", err)
				continue
			}
			goals = append(goals, goal)
		}

		// Return all goals as JSON
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"goals":   goals,
		})
	})

	router.POST("/goals", func(c *gin.Context) {
		// Track API request
		httpRequestsCounter.WithLabelValues("/goals").Inc()
		addGoalCounter.Inc()

		// Parse request body
		var requestBody struct {
			GoalName string `json:"goal_name"`
		}
		if err := c.BindJSON(&requestBody); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"error":   "Invalid request body",
			})
			return
		}

		// Validate goal name
		if requestBody.GoalName == "" {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"error":   "Goal name cannot be empty",
			})
			return
		}

		// Insert goal into database
		var newID int
		err := db.QueryRow("INSERT INTO goals (goal_name) VALUES ($1) RETURNING id", requestBody.GoalName).Scan(&newID)
		if err != nil {
			log.Println("Error inserting goal", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   "Error inserting goal into the database",
			})
			return
		}

		// Return new goal data
		c.JSON(http.StatusCreated, gin.H{
			"success": true,
			"goal": gin.H{
				"ID":   newID,
				"Name": requestBody.GoalName,
			},
		})
	})

	router.DELETE("/goals/:id", func(c *gin.Context) {
		// Track API request
		httpRequestsCounter.WithLabelValues("/goals/:id").Inc()
		removeGoalCounter.Inc()

		// Get goal ID from URL parameter
		goalID := c.Param("id")
		if goalID == "" {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"error":   "Goal ID parameter is required",
			})
			return
		}

		// Convert goal ID to integer
		id, err := strconv.Atoi(goalID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"error":   "Invalid goal ID format",
			})
			return
		}

		// Delete goal from database
		result, err := db.Exec("DELETE FROM goals WHERE id = $1", id)
		if err != nil {
			log.Println("Error deleting goal", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   "Error deleting goal from the database",
			})
			return
		}

		// Check if any rows were affected
		rowsAffected, err := result.RowsAffected()
		if err != nil {
			log.Println("Error checking rows affected", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   "Error checking if goal was deleted",
			})
			return
		}

		if rowsAffected == 0 {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"error":   "Goal not found",
			})
			return
		}

		// Return success response
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "Goal deleted successfully",
		})
	})

	// Add support for HTML template rendering (from reference code)
	if koDataPath := os.Getenv("KO_DATA_PATH"); koDataPath != "" {
		router.LoadHTMLGlob(koDataPath + "/*")

		router.GET("/", func(c *gin.Context) {
			// Get all goals from database
			rows, err := db.Query("SELECT id, goal_name FROM goals")
			if err != nil {
				log.Println("Error querying database", err)
				c.String(http.StatusInternalServerError, "Error querying the database")
				return
			}
			defer rows.Close()

			var goals []Goal
			for rows.Next() {
				var goal Goal
				if err := rows.Scan(&goal.ID, &goal.Name); err != nil {
					log.Println("Error scanning row", err)
					continue
				}
				goals = append(goals, goal)
			}

			httpRequestsCounter.WithLabelValues("/").Inc()

			c.HTML(http.StatusOK, "index.html", gin.H{
				"goals": goals,
			})
		})

		// Additional routes from reference code
		router.POST("/add_goal", func(c *gin.Context) {
			goalName := c.PostForm("goal_name")
			if goalName != "" {
				// Insert into database and get the new ID
				var newID int
				err := db.QueryRow("INSERT INTO goals (goal_name) VALUES ($1) RETURNING id", goalName).Scan(&newID)
				if err != nil {
					log.Println("Error inserting goal", err)
					c.JSON(http.StatusInternalServerError, gin.H{
						"success": false,
						"error":   "Error inserting goal into the database",
					})
					return
				}

				// Increment the add goal counter
				addGoalCounter.Inc()
				httpRequestsCounter.WithLabelValues("/add_goal").Inc()

				// Return JSON response with the new goal data
				c.JSON(http.StatusOK, gin.H{
					"success": true,
					"goal": gin.H{
						"ID":   newID,
						"Name": goalName,
					},
				})
			} else {
				c.JSON(http.StatusBadRequest, gin.H{
					"success": false,
					"error":   "Goal name cannot be empty",
				})
			}
		})

		router.POST("/remove_goal", func(c *gin.Context) {
			goalID := c.PostForm("goal_id")
			if goalID != "" {
				_, err = db.Exec("DELETE FROM goals WHERE id = $1", goalID)
				if err != nil {
					log.Println("Error deleting goal", err)
					c.JSON(http.StatusInternalServerError, gin.H{
						"success": false,
						"error":   "Error deleting goal from the database",
					})
					return
				}

				// Increment the remove goal counter
				removeGoalCounter.Inc()
				httpRequestsCounter.WithLabelValues("/remove_goal").Inc()

				c.JSON(http.StatusOK, gin.H{
					"success": true,
				})
			} else {
				c.JSON(http.StatusBadRequest, gin.H{
					"success": false,
					"error":   "Goal ID cannot be empty",
				})
			}
		})
	}

	router.GET("/health", func(c *gin.Context) {
		httpRequestsCounter.WithLabelValues("/health").Inc()
		c.String(http.StatusOK, "OK")
	})

	// Expose metrics endpoint
	router.GET("/metrics", gin.WrapH(promhttp.Handler()))

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	router.Run(":" + port)
}
