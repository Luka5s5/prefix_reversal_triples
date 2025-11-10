import shlex
import subprocess

from flask import Flask, Response, abort, render_template, request

app = Flask(__name__)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/compute", methods=["POST"])
def compute():
    try:
        # Get and validate parameters
        params = [
            float(request.form["param1"]),
            float(request.form["param2"]),
        ]
    except ValueError:
        abort(400, "Invalid input. Numbers required.")

    # Build command with sanitized inputs
    cmd = f"sage main.sage {params[0]} {params[1]}"

    # Generator function to stream output
    def generate():
        process = subprocess.Popen(
            shlex.split(cmd),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            universal_newlines=True,
        )

        # Stream output line-by-line
        try:
            for line in iter(process.stdout.readline, ""):
                yield line
        finally:
            process.stdout.close()
            process.wait()

    return Response(generate(), mimetype="text/plain")

@app.route("/compute1", methods=["POST"])
def compute1():
    try:
        # Get and validate parameters
        params = [
            int(request.form["param1"]),
            int(request.form["param2"]),
            int(request.form["param3"]),
            int(request.form["param4"]),
            int(request.form["param5"]),
            int(request.form["param6"]),
        ]
    except ValueError:
        abort(400, "Invalid input. Numbers required.")

    # Build command with sanitized inputs
    cmd = f"../a {params[0]} {params[1]} {params[2]} {params[3]} {params[4]} {params[5]}"

    # Generator function to stream output
    def generate():
        process = subprocess.Popen(
            shlex.split(cmd),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            universal_newlines=True,
        )

        # Stream output line-by-line
        try:
            for line in iter(process.stdout.readline, ""):
                yield line
        finally:
            process.stdout.close()
            process.wait()

    return Response(generate(), mimetype="text/plain")



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True, use_reloader=False)
