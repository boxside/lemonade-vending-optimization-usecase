from flask import Flask,jsonify,render_template
import socket
app = Flask(__name__)
# Funtion to fetch hostname and ip visitor
def fetchDetails():
    hostname = socket.gethostname()
    host_ip = socket.gethostbyname(hostname)
    return str(hostname),str(host_ip) 


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

@app.route("/health")
def health():
    return jsonify(
        status='UP'
        )

@app.route("/details")
def details():
    hostname,host_ip=fetchDetails()
    return render_template('index.html',hostname=hostname,host_ip=host_ip)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)