import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import { Geolocation } from '@capacitor/geolocation';
import { Shield, MapPin, Bell, Users, History, Settings, LogOut } from 'lucide-react';
import L from 'leaflet';
import './App.css';

// Fix for Leaflet default icon issues in React
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
    iconUrl: markerIcon,
    shadowUrl: markerShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

// Helper component to update map center
function ChangeView({ center, zoom }) {
  const map = useMap();
  map.setView(center, zoom);
  return null;
}

function App() {
  const [isEmergency, setIsEmergency] = useState(false);
  const [timer, setTimer] = useState(0);
  const [position, setPosition] = useState([28.6139, 77.2090]); // Default to Delhi
  const [locationName, setLocationName] = useState('Detecting...');

  // Effect for Timer
  useEffect(() => {
    let interval;
    if (isEmergency) {
      interval = setInterval(() => setTimer(t => t + 1), 1000);
    } else {
      setTimer(0);
      clearInterval(interval);
    }
    return () => clearInterval(interval);
  }, [isEmergency]);

  // Effect for Live Location
  useEffect(() => {
    const watchId = Geolocation.watchPosition({
      enableHighAccuracy: true,
      timeout: 10000
    }, (pos, err) => {
      if (pos) {
        const { latitude, longitude } = pos.coords;
        setPosition([latitude, longitude]);
        setLocationName(`${latitude.toFixed(4)}° N, ${longitude.toFixed(4)}° E`);
      }
    });

    return () => {
      if (watchId) Geolocation.clearWatch({ id: watchId });
    };
  }, []);

  const triggerSOS = async () => {
    const newState = !isEmergency;
    setIsEmergency(newState);

    if (newState) {
      // 1. Get current position
      const coordinates = await Geolocation.getCurrentPosition();
      const { latitude, longitude } = coordinates.coords;
      
      // 2. Prepare SMS Intent (Native Intent)
      const message = `EMERGENCY SOS! I need help. My location: https://www.google.com/maps?q=${latitude},${longitude}`;
      const phoneNumber = "9876543210"; // Replace with actual contact
      
      // Open SMS App
      window.location.href = `sms:${phoneNumber}?body=${encodeURIComponent(message)}`;
    }
  };

  const formatTime = (s) => {
    const mins = Math.floor(s / 60);
    const secs = s % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="dashboard">
      <main>
        <header>
          <h1>Guardian <span style={{color: 'var(--primary)'}}>SOS</span></h1>
          <div className={`status-badge ${isEmergency ? 'status-danger' : 'status-safe'}`}>
            {isEmergency ? 'Emergency Active' : 'System Secure'}
          </div>
        </header>

        <section className="sos-section">
          <button 
            className={`sos-trigger ${isEmergency ? 'active' : ''}`}
            onClick={triggerSOS}
          >
            {isEmergency ? 'STOP' : 'SOS'}
          </button>
          <div style={{ textAlign: 'center', marginTop: '1rem' }}>
            {isEmergency ? (
              <p className="timer">T-Plus: {formatTime(timer)}</p>
            ) : (
              <p style={{ color: 'var(--text-dim)' }}>Hold for 1.5s to trigger emergency alert</p>
            )}
          </div>
        </section>

        <section className="dashboard-grid">
          <div className="glass-card map-card">
            <div className="card-header">
              <div style={{ color: 'var(--primary)' }}><MapPin size={24} /></div>
              <h3>Live Location</h3>
            </div>
            <div className="mini-map-container">
              <MapContainer center={position} zoom={13} scrollWheelZoom={false} style={{ height: '180px', width: '100%', borderRadius: '12px' }}>
                <ChangeView center={position} zoom={13} />
                <TileLayer
                  attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                  url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />
                <Marker position={position}>
                  <Popup>User is here</Popup>
                </Marker>
              </MapContainer>
            </div>
            <p className="location-name">{locationName}</p>
          </div>
          <div className="glass-card">
            <div style={{ color: 'var(--secondary)', marginBottom: '0.5rem' }}><Users size={24} /></div>
            <h3>Contacts</h3>
            <p style={{ fontSize: '0.9rem', color: 'var(--text-dim)' }}>3 Active Receivers</p>
          </div>
          <div className="glass-card">
            <div style={{ color: '#ffaa00', marginBottom: '0.5rem' }}><Bell size={24} /></div>
            <h3>Notifications</h3>
            <p style={{ fontSize: '0.9rem', color: 'var(--text-dim)' }}>Alerts Sent via SMS/Push</p>
          </div>
        </section>
      </main>

      <aside className="glass-card">
        <h2 style={{ marginBottom: '1.5rem', fontSize: '1.2rem' }}>Menu</h2>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div className="nav-item"><History size={18} /> History</div>
          <div className="nav-item"><Users size={18} /> Contacts</div>
          <div className="nav-item"><Settings size={18} /> Settings</div>
          <div style={{ marginTop: 'auto', paddingTop: '2rem' }}>
            <div className="nav-item" style={{ color: '#ff4455' }}><LogOut size={18} /> Sign Out</div>
          </div>
        </nav>
      </aside>
    </div>
  );
}

export default App;
