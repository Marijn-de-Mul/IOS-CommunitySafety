from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from datetime import timedelta
import math
from flasgger import Swagger

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///community_safety.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = 'a6a5ab96aec6d1fd158b310cde7b8e5b61919c293eaf4c5344d783308f29aebb'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=31)

db = SQLAlchemy(app)
jwt = JWTManager(app)
swagger = Swagger(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(120), nullable=False)
    location = db.Column(db.String(120), nullable=True)

class Alert(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    severity = db.Column(db.Integer, nullable=False)
    location = db.Column(db.String(120), nullable=False)
    title = db.Column(db.String(120))
    description = db.Column(db.String(500))

    def to_dict(self):
        return {
            'id': self.id,
            'severity': self.severity,
            'location': self.location,
            'title': self.title,
            'description': self.description
        }

@app.route('/register', methods=['POST'])
def register():
    """
    Register a new user
    ---
    tags:
      - User
    parameters:
      - name: body
        in: body
        required: true
        schema:
          type: object
          required:
            - username
            - password
          properties:
            username:
              type: string
            password:
              type: string
            location:
              type: string
    responses:
      201:
        description: User registered successfully
      400:
        description: Invalid input
    """
    data = request.get_json()
    new_user = User(username=data['username'], password=data['password'], location=data.get('location'))
    db.session.add(new_user)
    db.session.commit()
    return jsonify(message="User registered successfully"), 201

@app.route('/login', methods=['POST'])
def login():
    """
    User login
    ---
    tags:
      - User
    parameters:
      - name: body
        in: body
        required: true
        schema:
          type: object
          required:
            - username
            - password
          properties:
            username:
              type: string
            password:
              type: string
    responses:
      200:
        description: Login successful
        schema:
          type: object
          properties:
            access_token:
              type: string
      401:
        description: Invalid credentials
    """
    data = request.get_json()
    user = User.query.filter_by(username=data['username'], password=data['password']).first()
    if user:
        access_token = create_access_token(identity=user.id)
        return jsonify(access_token=access_token), 200
    else:
        return jsonify(message="Invalid credentials"), 401

@app.route('/alerts', methods=['POST'])
@jwt_required()
def create_alert():
    """
    Create a new alert
    ---
    tags:
      - Alert
    parameters:
      - name: body
        in: body
        required: true
        schema:
          type: object
          required:
            - severity
            - location
          properties:
            severity:
              type: integer
            location:
              type: string
            title:
              type: string
            description:
              type: string
    responses:
      201:
        description: Alert created successfully
      400:
        description: Invalid input
    """
    data = request.get_json()
    new_alert = Alert(severity=data['severity'], location=data['location'], title=data.get('title'), description=data.get('description'))
    db.session.add(new_alert)
    db.session.commit()
    return jsonify(message="Alert created successfully"), 201

@app.route('/alerts/<int:alert_id>', methods=['PUT'])
@jwt_required()
def update_alert(alert_id):
    """
    Update an existing alert
    ---
    tags:
      - Alert
    parameters:
      - name: alert_id
        in: path
        required: true
        type: integer
      - name: body
        in: body
        required: true
        schema:
          type: object
          required:
            - severity
            - location
          properties:
            severity:
              type: integer
            location:
              type: string
            title:
              type: string
            description:
              type: string
    responses:
      200:
        description: Alert updated successfully
      404:
        description: Alert not found
    """
    data = request.get_json()
    alert = Alert.query.get_or_404(alert_id)
    alert.severity = data['severity']
    alert.location = data['location']
    alert.title = data.get('title')
    alert.description = data.get('description')
    db.session.commit()
    return jsonify(message="Alert updated successfully"), 200

@app.route('/alerts/<int:alert_id>', methods=['DELETE'])
@jwt_required()
def delete_alert(alert_id):
    """
    Delete an existing alert
    ---
    tags:
      - Alert
    parameters:
      - name: alert_id
        in: path
        required: true
        type: integer
    responses:
      200:
        description: Alert deleted successfully
      404:
        description: Alert not found
    """
    alert = Alert.query.get_or_404(alert_id)
    db.session.delete(alert)
    db.session.commit()
    return jsonify(message="Alert deleted successfully"), 200

@app.route('/alerts', methods=['GET'])
@jwt_required()
def get_alerts():
    """
    Get alerts based on severity and user location
    ---
    tags:
      - Alert
    parameters:
      - name: severity
        in: query
        required: true
        type: integer
    responses:
      200:
        description: List of alerts
        schema:
          type: array
          items:
            type: object
            properties:
              id:
                type: integer
              severity:
                type: integer
              location:
                type: string
              title:
                type: string
              description:
                type: string
      400:
        description: User location not set
    """
    severity = request.args.get('severity', type=int)
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    user_location = user.location

    if not user_location:
        return jsonify(message="User location not set"), 400

    alerts = Alert.query.filter_by(severity=severity).all()
    filtered_alerts = [alert for alert in alerts if is_within_range(user_location, alert.location, severity)]
    return jsonify(alerts=[alert.to_dict() for alert in filtered_alerts]), 200

@app.route('/update_location', methods=['PUT'])
@jwt_required()
def update_location():
    """
    Update user location
    ---
    tags:
      - User
    parameters:
      - name: body
        in: body
        required: true
        schema:
          type: object
          required:
            - location
          properties:
            location:
              type: string
    responses:
      200:
        description: Location updated successfully
    """
    data = request.get_json()
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    user.location = data['location']
    db.session.commit()
    return jsonify(message="Location updated successfully"), 200

def is_within_range(user_location, alert_location, severity):
    user_lat, user_lon = map(float, user_location.split(','))
    alert_lat, alert_lon = map(float, alert_location.split(','))
    distance = calculate_distance(user_lat, user_lon, alert_lat, alert_lon)
    return distance <= severity * 3

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371  # Radius of the Earth in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lat2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    distance = R * c
    return distance

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)