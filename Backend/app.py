from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from datetime import timedelta
import math
from flasgger import Swagger, swag_from
import logging

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///community_safety.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = 'a6a5ab96aec6d1fd158b310cde7b8e5b61919c293eaf4c5344d783308f29aebb'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=31)

db = SQLAlchemy(app)
jwt = JWTManager(app)
swagger = Swagger(app)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.before_request
def log_request_info():
    logger.info(f"Request: {request.method} {request.url}")
    logger.info(f"Headers: {request.headers}")
    logger.info(f"Body: {request.get_data()}")

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=True)
    longitude = db.Column(db.Float, nullable=True)

class Alert(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    severity = db.Column(db.Integer, nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    title = db.Column(db.String(120))
    description = db.Column(db.String(500))

    def to_dict(self):
        return {
            'id': self.id,
            'severity': self.severity,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'title': self.title,
            'description': self.description
        }

@app.route('/register', methods=['POST'])
@swag_from({
    'responses': {
        201: {
            'description': 'User registered successfully',
            'examples': {
                'application/json': {
                    'message': 'User registered successfully'
                }
            }
        }
    }
})
def register():
    data = request.get_json()
    new_user = User(username=data['username'], password=data['password'], latitude=data.get('latitude'), longitude=data.get('longitude'))
    db.session.add(new_user)
    db.session.commit()
    return jsonify(message="User registered successfully"), 201

@app.route('/login', methods=['POST'])
@swag_from({
    'responses': {
        200: {
            'description': 'Login successful',
            'examples': {
                'application/json': {
                    'access_token': 'your_access_token'
                }
            }
        },
        401: {
            'description': 'Invalid credentials',
            'examples': {
                'application/json': {
                    'message': 'Invalid credentials'
                }
            }
        }
    }
})
def login():
    data = request.get_json()
    user = User.query.filter_by(username=data['username']).first()
    if user and user.password == data['password']:
        access_token = create_access_token(identity=user.id)
        return jsonify(access_token=access_token), 200
    return jsonify(message="Invalid credentials"), 401

@app.route('/update_location', methods=['PUT'])
@jwt_required()
@swag_from({
    'responses': {
        200: {
            'description': 'Location updated successfully',
            'examples': {
                'application/json': {
                    'message': 'Location updated successfully'
                }
            }
        }
    }
})
def update_location():
    data = request.get_json()
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    user.latitude = data['latitude']
    user.longitude = data['longitude']
    db.session.commit()
    return jsonify(message="Location updated successfully"), 200

@app.route('/alerts', methods=['POST'])
@jwt_required()
@swag_from({
    'responses': {
        201: {
            'description': 'Alert created successfully',
            'examples': {
                'application/json': {
                    'message': 'Alert created successfully'
                }
            }
        }
    }
})
def create_alert():
    data = request.get_json()
    new_alert = Alert(severity=data['severity'], latitude=data['latitude'], longitude=data['longitude'], title=data.get('title'), description=data.get('description'))
    db.session.add(new_alert)
    db.session.commit()
    return jsonify(message="Alert created successfully"), 201

@app.route('/alerts/<int:alert_id>', methods=['PUT'])
@jwt_required()
@swag_from({
    'responses': {
        200: {
            'description': 'Alert updated successfully',
            'examples': {
                'application/json': {
                    'message': 'Alert updated successfully'
                }
            }
        }
    }
})
def update_alert(alert_id):
    data = request.get_json()
    alert = Alert.query.get_or_404(alert_id)
    alert.severity = data['severity']
    alert.latitude = data['latitude']
    alert.longitude = data['longitude']
    alert.title = data.get('title')
    alert.description = data.get('description')
    db.session.commit()
    return jsonify(message="Alert updated successfully"), 200

@app.route('/alerts', methods=['GET'])
@jwt_required()
@swag_from({
    'responses': {
        200: {
            'description': 'List of alerts',
            'examples': {
                'application/json': {
                    'alerts': [
                        {
                            'id': 1,
                            'severity': 3,
                            'latitude': 52.3676,
                            'longitude': 4.9041,
                            'title': 'Test Alert',
                            'description': 'This is a test alert'
                        }
                    ]
                }
            }
        }
    }
})
def get_alerts():
    severity = request.args.get('severity', type=int)
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    user_latitude = user.latitude
    user_longitude = user.longitude

    if user_latitude is None or user_longitude is None:
        return jsonify(message="User location not set"), 400

    alerts = Alert.query.filter_by(severity=severity).all()
    filtered_alerts = [alert for alert in alerts if is_within_range(user_latitude, user_longitude, alert.latitude, alert.longitude, severity)]
    return jsonify(alerts=[alert.to_dict() for alert in filtered_alerts]), 200

def is_within_range(user_latitude, user_longitude, alert_latitude, alert_longitude, severity):
    distance = calculate_distance(user_latitude, user_longitude, alert_latitude, alert_longitude)
    return distance <= severity * 3

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371  # Radius of the Earth in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    distance = R * c
    return distance

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', debug=True)