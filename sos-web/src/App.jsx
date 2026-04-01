import React, { useState, useEffect } from 'react';
import { Shield, MapPin, Bell, Users, History, Settings, LogOut } from 'lucide-react';
import './App.css';

function App() {
  const [isEmergency, setIsEmergency] = useState(false);
  const [timer, setTimer] = useState(0);

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
            className="sos-trigger"
            onHold={() => setIsEmergency(true)} // Simulated hold
            onClick={() => setIsEmergency(!isEmergency)}
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

        <section className="dashboard-grid" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem', marginTop: '2rem' }}>
          <div className="glass-card">
            <div style={{ color: 'var(--primary)', marginBottom: '0.5rem' }}><MapPin size={24} /></div>
            <h3>Live Location</h3>
            <p style={{ fontSize: '0.9rem', color: 'var(--text-dim)' }}>28.6139° N, 77.2090° E</p>
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
