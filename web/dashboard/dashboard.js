// Katya Dashboard JavaScript

class DashboardApp {
    constructor() {
        this.widgets = new Map();
        this.charts = new Map();
        this.refreshIntervals = new Map();
        this.isDarkMode = false;
        this.currentTheme = 'light';
        
        this.init();
    }

    async init() {
        console.log('Initializing Katya Dashboard...');
        
        // Initialize dashboard
        await this.loadDashboardData();
        this.setupEventListeners();
        this.initializeCharts();
        this.startAutoRefresh();
        
        // Update last updated time
        this.updateLastUpdatedTime();
        
        console.log('Dashboard initialized successfully');
    }

    async loadDashboardData() {
        try {
            // Load widgets data
            const widgets = await this.fetchWidgetData();
            this.updateWidgets(widgets);
            
            // Load system status
            const systemStatus = await this.fetchSystemStatus();
            this.updateSystemStatus(systemStatus);
            
            // Load alerts
            const alerts = await this.fetchAlerts();
            this.updateAlerts(alerts);
            
        } catch (error) {
            console.error('Error loading dashboard data:', error);
            this.showError('Failed to load dashboard data');
        }
    }

    async fetchWidgetData() {
        // Simulate API call
        await this.delay(500);
        
        return {
            'cpu_metric': {
                value: (Math.random() * 100).toFixed(1),
                change: (Math.random() * 10 - 5).toFixed(1),
                trend: Math.random() > 0.5 ? 'up' : 'down'
            },
            'memory_metric': {
                value: (Math.random() * 100).toFixed(1),
                change: (Math.random() * 10 - 5).toFixed(1),
                trend: Math.random() > 0.5 ? 'up' : 'down'
            },
            'performance_chart': {
                data: this.generatePerformanceData()
            },
            'alerts_list': {
                alerts: this.generateAlertsData()
            },
            'system_status': {
                services: this.generateSystemStatusData()
            },
            'user_activity': {
                activities: this.generateActivityData()
            }
        };
    }

    async fetchSystemStatus() {
        await this.delay(200);
        return {
            overall: 'healthy',
            uptime: '99.9%',
            activeUsers: Math.floor(Math.random() * 1000) + 500
        };
    }

    async fetchAlerts() {
        await this.delay(300);
        return this.generateAlertsData();
    }

    updateWidgets(data) {
        // Update CPU metric
        if (data.cpu_metric) {
            this.updateMetricWidget('cpu_metric', data.cpu_metric);
        }

        // Update Memory metric
        if (data.memory_metric) {
            this.updateMetricWidget('memory_metric', data.memory_metric);
        }

        // Update Performance chart
        if (data.performance_chart) {
            this.updatePerformanceChart(data.performance_chart.data);
        }

        // Update Alerts list
        if (data.alerts_list) {
            this.updateAlertsList(data.alerts_list.alerts);
        }

        // Update System status
        if (data.system_status) {
            this.updateSystemStatusWidget(data.system_status.services);
        }

        // Update User activity
        if (data.user_activity) {
            this.updateUserActivity(data.user_activity.activities);
        }
    }

    updateMetricWidget(widgetId, data) {
        const widget = document.getElementById(widgetId);
        if (!widget) return;

        // Update value
        const valueElement = widget.querySelector('.metric-value .value');
        if (valueElement) {
            valueElement.textContent = data.value;
        }

        // Update change
        const changeElement = widget.querySelector('.metric-change .change');
        if (changeElement) {
            changeElement.textContent = `${data.change}%`;
            changeElement.className = `change ${data.trend === 'up' ? 'positive' : 'negative'}`;
            
            const icon = changeElement.querySelector('i');
            if (icon) {
                icon.className = data.trend === 'up' ? 'fas fa-arrow-up' : 'fas fa-arrow-down';
            }
        }

        // Update mini chart
        this.updateMiniChart(widgetId, data);
    }

    updateMiniChart(widgetId, data) {
        const canvas = document.getElementById(`${widgetId.replace('_metric', '')}Chart`);
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        const width = canvas.width;
        const height = canvas.height;

        // Clear canvas
        ctx.clearRect(0, 0, width, height);

        // Generate data points
        const dataPoints = [];
        let currentValue = parseFloat(data.value);
        
        for (let i = 0; i < 20; i++) {
            currentValue += (Math.random() - 0.5) * 5;
            currentValue = Math.max(0, Math.min(100, currentValue));
            dataPoints.push(currentValue);
        }

        // Draw chart
        ctx.strokeStyle = data.trend === 'up' ? '#e74c3c' : '#27ae60';
        ctx.lineWidth = 2;
        ctx.beginPath();

        dataPoints.forEach((value, index) => {
            const x = (index / (dataPoints.length - 1)) * width;
            const y = height - (value / 100) * height;
            
            if (index === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        });

        ctx.stroke();
    }

    updatePerformanceChart(data) {
        const canvas = document.getElementById('performanceChart');
        if (!canvas) return;

        if (this.charts.has('performance')) {
            this.charts.get('performance').destroy();
        }

        const ctx = canvas.getContext('2d');
        const chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: data.labels || this.generateTimeLabels(),
                datasets: [
                    {
                        label: 'CPU',
                        data: data.cpu || this.generateRandomData(30),
                        borderColor: '#3498db',
                        backgroundColor: 'rgba(52, 152, 219, 0.1)',
                        tension: 0.4
                    },
                    {
                        label: 'Memory',
                        data: data.memory || this.generateRandomData(30),
                        borderColor: '#e74c3c',
                        backgroundColor: 'rgba(231, 76, 60, 0.1)',
                        tension: 0.4
                    },
                    {
                        label: 'Disk',
                        data: data.disk || this.generateRandomData(30),
                        borderColor: '#f39c12',
                        backgroundColor: 'rgba(243, 156, 18, 0.1)',
                        tension: 0.4
                    },
                    {
                        label: 'Network',
                        data: data.network || this.generateRandomData(30),
                        borderColor: '#2ecc71',
                        backgroundColor: 'rgba(46, 204, 113, 0.1)',
                        tension: 0.4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false // We have custom legend
                    }
                },
                scales: {
                    x: {
                        display: false
                    },
                    y: {
                        beginAtZero: true,
                        max: 100,
                        ticks: {
                            callback: function(value) {
                                return value + '%';
                            }
                        }
                    }
                },
                elements: {
                    point: {
                        radius: 0
                    }
                }
            }
        });

        this.charts.set('performance', chart);
    }

    updateAlertsList(alerts) {
        const alertsContainer = document.querySelector('#alerts_list .alerts-list');
        if (!alertsContainer) return;

        alertsContainer.innerHTML = '';

        alerts.forEach(alert => {
            const alertElement = this.createAlertElement(alert);
            alertsContainer.appendChild(alertElement);
        });
    }

    createAlertElement(alert) {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert-item ${alert.severity}`;
        alertDiv.innerHTML = `
            <div class="alert-icon">
                <i class="fas ${this.getAlertIcon(alert.severity)}"></i>
            </div>
            <div class="alert-content">
                <div class="alert-title">${alert.title}</div>
                <div class="alert-message">${alert.message}</div>
                <div class="alert-time">${this.formatTime(alert.timestamp)}</div>
            </div>
            <div class="alert-actions">
                <button class="alert-action" onclick="dashboard.acknowledgeAlert('${alert.id}')">
                    <i class="fas fa-check"></i>
                </button>
            </div>
        `;
        return alertDiv;
    }

    updateSystemStatusWidget(services) {
        const statusContainer = document.querySelector('#system_status .status-list');
        if (!statusContainer) return;

        statusContainer.innerHTML = '';

        services.forEach(service => {
            const statusElement = this.createStatusElement(service);
            statusContainer.appendChild(statusElement);
        });
    }

    createStatusElement(service) {
        const statusDiv = document.createElement('div');
        statusDiv.className = 'status-item';
        statusDiv.innerHTML = `
            <div class="status-icon ${service.status}">
                <i class="fas ${this.getStatusIcon(service.status)}"></i>
            </div>
            <div class="status-info">
                <div class="status-name">${service.name}</div>
                <div class="status-detail">${service.uptime} uptime</div>
            </div>
        `;
        return statusDiv;
    }

    updateUserActivity(activities) {
        const activityContainer = document.querySelector('#user_activity .activity-list');
        if (!activityContainer) return;

        activityContainer.innerHTML = '';

        activities.forEach(activity => {
            const activityElement = this.createActivityElement(activity);
            activityContainer.appendChild(activityElement);
        });
    }

    createActivityElement(activity) {
        const activityDiv = document.createElement('div');
        activityDiv.className = 'activity-item';
        activityDiv.innerHTML = `
            <div class="activity-icon">
                <i class="fas ${this.getActivityIcon(activity.action)}"></i>
            </div>
            <div class="activity-content">
                <div class="activity-title">${activity.title}</div>
                <div class="activity-detail">${activity.detail}</div>
                <div class="activity-time">${this.formatTime(activity.timestamp)}</div>
            </div>
        `;
        return activityDiv;
    }

    updateSystemStatus(status) {
        // Update sidebar status
        const statusElements = document.querySelectorAll('.system-status .status-value');
        if (statusElements.length >= 3) {
            statusElements[0].innerHTML = `<i class="fas fa-check-circle"></i> ${status.overall}`;
            statusElements[1].textContent = status.uptime;
            statusElements[2].textContent = status.activeUsers.toLocaleString();
        }
    }

    updateAlerts(alerts) {
        const alertsSummary = document.getElementById('alertsSummary');
        if (!alertsSummary) return;

        alertsSummary.innerHTML = '';

        const criticalAlerts = alerts.filter(alert => alert.severity === 'critical');
        const warningAlerts = alerts.filter(alert => alert.severity === 'warning');

        if (criticalAlerts.length > 0) {
            const alertElement = document.createElement('div');
            alertElement.className = 'alert-item critical';
            alertElement.innerHTML = `
                <i class="fas fa-exclamation-circle"></i>
                <span>${criticalAlerts.length} Critical Alert${criticalAlerts.length > 1 ? 's' : ''}</span>
            `;
            alertsSummary.appendChild(alertElement);
        }

        if (warningAlerts.length > 0) {
            const alertElement = document.createElement('div');
            alertElement.className = 'alert-item warning';
            alertElement.innerHTML = `
                <i class="fas fa-exclamation-triangle"></i>
                <span>${warningAlerts.length} Warning${warningAlerts.length > 1 ? 's' : ''}</span>
            `;
            alertsSummary.appendChild(alertElement);
        }

        if (alerts.length === 0) {
            const noAlertsElement = document.createElement('div');
            noAlertsElement.className = 'alert-item info';
            noAlertsElement.innerHTML = `
                <i class="fas fa-check-circle"></i>
                <span>No Active Alerts</span>
            `;
            alertsSummary.appendChild(noAlertsElement);
        }
    }

    setupEventListeners() {
        // Navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                this.setActiveNavItem(item);
            });
        });

        // Search
        const searchInput = document.querySelector('.search-box input');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                this.handleSearch(e.target.value);
            });
        }

        // User menu
        const userMenu = document.querySelector('.user-menu');
        if (userMenu) {
            userMenu.addEventListener('click', () => {
                this.toggleUserMenu();
            });
        }

        // Theme toggle
        window.toggleTheme = () => this.toggleTheme();
        window.refreshAllWidgets = () => this.refreshAllWidgets();
        window.exportDashboard = () => this.exportDashboard();
        window.refreshWidget = (widgetId) => this.refreshWidget(widgetId);
        window.configureWidget = (widgetId) => this.configureWidget(widgetId);
        window.acknowledgeAlert = (alertId) => this.acknowledgeAlert(alertId);
        window.closeModal = (modalId) => this.closeModal(modalId);
        window.saveWidgetConfig = () => this.saveWidgetConfig();

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            this.handleKeyboardShortcuts(e);
        });

        // Window resize
        window.addEventListener('resize', () => {
            this.handleResize();
        });
    }

    initializeCharts() {
        // Initialize mini charts for metric widgets
        this.initializeMiniCharts();
    }

    initializeMiniCharts() {
        // CPU Chart
        const cpuCanvas = document.getElementById('cpuChart');
        if (cpuCanvas) {
            this.drawMiniChart(cpuCanvas, '#3498db');
        }

        // Memory Chart
        const memoryCanvas = document.getElementById('memoryChart');
        if (memoryCanvas) {
            this.drawMiniChart(memoryCanvas, '#e74c3c');
        }
    }

    drawMiniChart(canvas, color) {
        const ctx = canvas.getContext('2d');
        const width = canvas.width;
        const height = canvas.height;

        // Generate sample data
        const dataPoints = [];
        for (let i = 0; i < 20; i++) {
            dataPoints.push(Math.random() * 100);
        }

        // Draw chart
        ctx.strokeStyle = color;
        ctx.lineWidth = 2;
        ctx.beginPath();

        dataPoints.forEach((value, index) => {
            const x = (index / (dataPoints.length - 1)) * width;
            const y = height - (value / 100) * height;
            
            if (index === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        });

        ctx.stroke();
    }

    startAutoRefresh() {
        // Refresh widgets every 30 seconds
        setInterval(() => {
            this.refreshAllWidgets();
        }, 30000);

        // Update time every minute
        setInterval(() => {
            this.updateLastUpdatedTime();
        }, 60000);
    }

    async refreshAllWidgets() {
        console.log('Refreshing all widgets...');
        
        try {
            await this.loadDashboardData();
            this.showSuccess('Dashboard refreshed successfully');
        } catch (error) {
            console.error('Error refreshing widgets:', error);
            this.showError('Failed to refresh dashboard');
        }
    }

    async refreshWidget(widgetId) {
        console.log(`Refreshing widget: ${widgetId}`);
        
        try {
            const widget = document.getElementById(widgetId);
            if (widget) {
                widget.classList.add('loading');
            }

            const data = await this.fetchWidgetData();
            if (data[widgetId]) {
                this.updateWidgets({ [widgetId]: data[widgetId] });
            }

            if (widget) {
                widget.classList.remove('loading');
            }

            this.showSuccess(`Widget ${widgetId} refreshed`);
        } catch (error) {
            console.error(`Error refreshing widget ${widgetId}:`, error);
            this.showError(`Failed to refresh widget ${widgetId}`);
        }
    }

    configureWidget(widgetId) {
        console.log(`Configuring widget: ${widgetId}`);
        
        const modal = document.getElementById('widgetConfigModal');
        if (modal) {
            modal.classList.add('show');
            
            // Pre-populate form with current widget settings
            const widget = document.getElementById(widgetId);
            if (widget) {
                const title = widget.querySelector('h3')?.textContent || '';
                const form = document.getElementById('widgetConfigForm');
                if (form) {
                    form.widgetTitle.value = title;
                    form.dataset.widgetId = widgetId;
                }
            }
        }
    }

    saveWidgetConfig() {
        const form = document.getElementById('widgetConfigForm');
        if (!form) return;

        const widgetId = form.dataset.widgetId;
        const title = form.widgetTitle.value;
        const refreshInterval = form.refreshInterval.value;

        console.log(`Saving config for widget: ${widgetId}`);
        console.log('Title:', title);
        console.log('Refresh Interval:', refreshInterval);

        // Update widget title
        const widget = document.getElementById(widgetId);
        if (widget) {
            const titleElement = widget.querySelector('h3');
            if (titleElement) {
                titleElement.textContent = title;
            }
        }

        // Close modal
        this.closeModal('widgetConfigModal');
        
        this.showSuccess('Widget configuration saved');
    }

    acknowledgeAlert(alertId) {
        console.log(`Acknowledging alert: ${alertId}`);
        
        // Remove alert from UI
        const alertElement = document.querySelector(`[onclick*="${alertId}"]`)?.closest('.alert-item');
        if (alertElement) {
            alertElement.style.opacity = '0.5';
            alertElement.style.pointerEvents = 'none';
        }

        this.showSuccess('Alert acknowledged');
    }

    exportDashboard() {
        console.log('Exporting dashboard...');
        
        const data = {
            timestamp: new Date().toISOString(),
            widgets: Array.from(document.querySelectorAll('.widget')).map(widget => ({
                id: widget.id,
                title: widget.querySelector('h3')?.textContent || '',
                type: widget.className.split(' ')[1]
            })),
            systemStatus: {
                overall: document.querySelector('.system-status .status-value')?.textContent || '',
                uptime: document.querySelectorAll('.system-status .status-value')[1]?.textContent || '',
                activeUsers: document.querySelectorAll('.system-status .status-value')[2]?.textContent || ''
            }
        };

        const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `katya-dashboard-${new Date().toISOString().split('T')[0]}.json`;
        a.click();
        URL.revokeObjectURL(url);

        this.showSuccess('Dashboard exported successfully');
    }

    toggleTheme() {
        this.isDarkMode = !this.isDarkMode;
        this.currentTheme = this.isDarkMode ? 'dark' : 'light';
        
        document.documentElement.setAttribute('data-theme', this.currentTheme);
        
        const themeButton = document.querySelector('[onclick="toggleTheme()"]');
        if (themeButton) {
            const icon = themeButton.querySelector('i');
            if (icon) {
                icon.className = this.isDarkMode ? 'fas fa-sun' : 'fas fa-moon';
            }
            themeButton.innerHTML = `
                <i class="fas ${this.isDarkMode ? 'fa-sun' : 'fa-moon'}"></i>
                ${this.isDarkMode ? 'Light' : 'Dark'} Mode
            `;
        }

        // Save theme preference
        localStorage.setItem('dashboard-theme', this.currentTheme);
        
        this.showSuccess(`Switched to ${this.currentTheme} theme`);
    }

    setActiveNavItem(activeItem) {
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        activeItem.classList.add('active');
    }

    handleSearch(query) {
        console.log('Searching for:', query);
        
        if (!query.trim()) {
            // Show all widgets
            document.querySelectorAll('.widget').forEach(widget => {
                widget.style.display = 'block';
            });
            return;
        }

        // Filter widgets based on search query
        document.querySelectorAll('.widget').forEach(widget => {
            const title = widget.querySelector('h3')?.textContent.toLowerCase() || '';
            const content = widget.textContent.toLowerCase();
            
            if (title.includes(query.toLowerCase()) || content.includes(query.toLowerCase())) {
                widget.style.display = 'block';
            } else {
                widget.style.display = 'none';
            }
        });
    }

    toggleUserMenu() {
        console.log('Toggling user menu...');
        // Implementation for user menu dropdown
    }

    handleKeyboardShortcuts(e) {
        // Ctrl/Cmd + R: Refresh all widgets
        if ((e.ctrlKey || e.metaKey) && e.key === 'r') {
            e.preventDefault();
            this.refreshAllWidgets();
        }
        
        // Ctrl/Cmd + E: Export dashboard
        if ((e.ctrlKey || e.metaKey) && e.key === 'e') {
            e.preventDefault();
            this.exportDashboard();
        }
        
        // Escape: Close modals
        if (e.key === 'Escape') {
            this.closeAllModals();
        }
    }

    handleResize() {
        // Update charts on resize
        this.charts.forEach(chart => {
            if (chart && typeof chart.resize === 'function') {
                chart.resize();
            }
        });
    }

    closeModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.remove('show');
        }
    }

    closeAllModals() {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.classList.remove('show');
        });
    }

    updateLastUpdatedTime() {
        const lastUpdatedElement = document.getElementById('lastUpdated');
        if (lastUpdatedElement) {
            lastUpdatedElement.textContent = new Date().toLocaleTimeString();
        }
    }

    showSuccess(message) {
        this.showNotification(message, 'success');
    }

    showError(message) {
        this.showNotification(message, 'error');
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        // Style notification
        Object.assign(notification.style, {
            position: 'fixed',
            top: '20px',
            right: '20px',
            padding: '12px 20px',
            borderRadius: '6px',
            color: 'white',
            fontWeight: '500',
            zIndex: '10000',
            transform: 'translateX(100%)',
            transition: 'transform 0.3s ease-in-out',
            backgroundColor: type === 'success' ? '#27ae60' : type === 'error' ? '#e74c3c' : '#3498db'
        });
        
        document.body.appendChild(notification);
        
        // Animate in
        setTimeout(() => {
            notification.style.transform = 'translateX(0)';
        }, 100);
        
        // Remove after 3 seconds
        setTimeout(() => {
            notification.style.transform = 'translateX(100%)';
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 3000);
    }

    // Utility functions
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    generatePerformanceData() {
        return {
            labels: this.generateTimeLabels(),
            cpu: this.generateRandomData(30),
            memory: this.generateRandomData(30),
            disk: this.generateRandomData(30),
            network: this.generateRandomData(30)
        };
    }

    generateTimeLabels() {
        const labels = [];
        const now = new Date();
        for (let i = 29; i >= 0; i--) {
            const time = new Date(now.getTime() - i * 60000);
            labels.push(time.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }));
        }
        return labels;
    }

    generateRandomData(count) {
        const data = [];
        let value = 50;
        for (let i = 0; i < count; i++) {
            value += (Math.random() - 0.5) * 10;
            value = Math.max(0, Math.min(100, value));
            data.push(Math.round(value));
        }
        return data;
    }

    generateAlertsData() {
        const alerts = [
            {
                id: 'alert_1',
                title: 'High CPU Usage',
                message: 'CPU usage is at 85.2%',
                severity: 'critical',
                timestamp: new Date(Date.now() - 2 * 60000)
            },
            {
                id: 'alert_2',
                title: 'Memory Warning',
                message: 'Memory usage is at 78.5%',
                severity: 'warning',
                timestamp: new Date(Date.now() - 5 * 60000)
            },
            {
                id: 'alert_3',
                title: 'System Update',
                message: 'System update completed successfully',
                severity: 'info',
                timestamp: new Date(Date.now() - 60 * 60000)
            }
        ];
        return alerts;
    }

    generateSystemStatusData() {
        return [
            { name: 'Database', status: 'healthy', uptime: '99.9%' },
            { name: 'Cache', status: 'healthy', uptime: '99.8%' },
            { name: 'API', status: 'healthy', uptime: '99.7%' },
            { name: 'WebSocket', status: 'warning', uptime: '98.5%' }
        ];
    }

    generateActivityData() {
        const activities = [
            {
                title: 'User Registration',
                detail: 'New user john.doe@example.com registered',
                action: 'user-plus',
                timestamp: new Date(Date.now() - 2 * 60000)
            },
            {
                title: 'Message Sent',
                detail: 'User sent message in room #general',
                action: 'comment',
                timestamp: new Date(Date.now() - 5 * 60000)
            },
            {
                title: 'File Upload',
                detail: 'User uploaded document.pdf',
                action: 'upload',
                timestamp: new Date(Date.now() - 10 * 60000)
            },
            {
                title: 'File Download',
                detail: 'User downloaded report.xlsx',
                action: 'download',
                timestamp: new Date(Date.now() - 15 * 60000)
            }
        ];
        return activities;
    }

    getAlertIcon(severity) {
        switch (severity) {
            case 'critical': return 'fa-exclamation-circle';
            case 'warning': return 'fa-exclamation-triangle';
            case 'info': return 'fa-info-circle';
            default: return 'fa-bell';
        }
    }

    getStatusIcon(status) {
        switch (status) {
            case 'healthy': return 'fa-check-circle';
            case 'warning': return 'fa-exclamation-triangle';
            case 'critical': return 'fa-times-circle';
            default: return 'fa-question-circle';
        }
    }

    getActivityIcon(action) {
        switch (action) {
            case 'user-plus': return 'fa-user-plus';
            case 'comment': return 'fa-comment';
            case 'upload': return 'fa-upload';
            case 'download': return 'fa-download';
            case 'login': return 'fa-sign-in-alt';
            case 'logout': return 'fa-sign-out-alt';
            default: return 'fa-circle';
        }
    }

    formatTime(timestamp) {
        const now = new Date();
        const diff = now - timestamp;
        const minutes = Math.floor(diff / 60000);
        const hours = Math.floor(diff / 3600000);
        const days = Math.floor(diff / 86400000);

        if (minutes < 1) return 'Just now';
        if (minutes < 60) return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
        if (hours < 24) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
        return `${days} day${days > 1 ? 's' : ''} ago`;
    }
}

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new DashboardApp();
});

// Global functions for HTML onclick handlers
function refreshAllWidgets() {
    if (window.dashboard) {
        window.dashboard.refreshAllWidgets();
    }
}

function exportDashboard() {
    if (window.dashboard) {
        window.dashboard.exportDashboard();
    }
}

function toggleTheme() {
    if (window.dashboard) {
        window.dashboard.toggleTheme();
    }
}

function refreshWidget(widgetId) {
    if (window.dashboard) {
        window.dashboard.refreshWidget(widgetId);
    }
}

function configureWidget(widgetId) {
    if (window.dashboard) {
        window.dashboard.configureWidget(widgetId);
    }
}

function acknowledgeAlert(alertId) {
    if (window.dashboard) {
        window.dashboard.acknowledgeAlert(alertId);
    }
}

function closeModal(modalId) {
    if (window.dashboard) {
        window.dashboard.closeModal(modalId);
    }
}

function saveWidgetConfig() {
    if (window.dashboard) {
        window.dashboard.saveWidgetConfig();
    }
}
