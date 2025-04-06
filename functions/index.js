const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { google } = require("googleapis");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Google Calendar API Setup
const calendar = google.calendar("v3");

// Your OAuth2 credentials from Google Cloud Console
const CLIENT_ID = "YOUR_CLIENT_ID";
const CLIENT_SECRET = "YOUR_CLIENT_SECRET";
const REDIRECT_URI = "YOUR_REDIRECT_URI";
const REFRESH_TOKEN = "YOUR_REFRESH_TOKEN";

const oauth2Client = new google.auth.OAuth2(
  CLIENT_ID,
  CLIENT_SECRET,
  REDIRECT_URI
);

// Set the refresh token to authenticate
oauth2Client.setCredentials({ refresh_token: REFRESH_TOKEN });

// Firebase Function to Fetch Events
exports.getCalendarEvents = functions.https.onRequest(async (req, res) => {
  try {
    const response = await calendar.events.list({
      auth: oauth2Client,
      calendarId: "primary",
      timeMin: new Date().toISOString(),
      maxResults: 10,
      singleEvents: true,
      orderBy: "startTime",
    });

    res.status(200).json(response.data.items);
  } catch (error) {
    console.error("Error fetching calendar events:", error);
    res.status(500).send("Error fetching calendar events");
  }
});

// Firebase Function to Add an Event
exports.addCalendarEvent = functions.https.onRequest(async (req, res) => {
  try {
    const event = {
      summary: req.body.summary || "New Event",
      start: { dateTime: req.body.startTime, timeZone: "America/New_York" },
      end: { dateTime: req.body.endTime, timeZone: "America/New_York" },
    };

    const response = await calendar.events.insert({
      auth: oauth2Client,
      calendarId: "primary",
      resource: event,
    });

    res.status(200).json(response.data);
  } catch (error) {
    console.error("Error adding event:", error);
    res.status(500).send("Error adding event");
  }
});
