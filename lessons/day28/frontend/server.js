const express = require('express');
const path = require('path');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8080';

// Enable CORS
app.use(cors());

// Middleware to parse request bodies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// API proxy routes to forward requests to the backend
app.post('/api/goals', async (req, res) => {
  try {
    const response = await fetch(`${BACKEND_URL}/goals`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(req.body),
    });
    
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Error adding goal:', error);
    res.status(500).json({ success: false, error: 'Failed to add goal' });
  }
});

app.delete('/api/goals/:id', async (req, res) => {
  try {
    const response = await fetch(`${BACKEND_URL}/goals/${req.params.id}`, {
      method: 'DELETE',
    });
    
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Error removing goal:', error);
    res.status(500).json({ success: false, error: 'Failed to remove goal' });
  }
});

app.get('/api/goals', async (req, res) => {
  try {
    const response = await fetch(`${BACKEND_URL}/goals`);
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Error fetching goals:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch goals' });
  }
});

// Serve the main page for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Frontend server running on http://localhost:${PORT}`);
});