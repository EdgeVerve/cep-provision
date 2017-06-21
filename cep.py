from __future__ import print_function
import sys, subprocess, string,cStringIO, cgi,time,datetime,json
from os import curdir, sep
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from urlparse import urlparse, parse_qs

logfile = open('./cep.log', 'w')
logfile.truncate()


def execute(cmd):
    logfile = open('./cep.log', 'w')
    popen = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        logfile.write(stdout_line)
        yield stdout_line 
    popen.stdout.close()
    logfile.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)



class MyHandler(BaseHTTPRequestHandler):

  def do_GET(self):
    try:
        if self.path.endswith(".html"):
            f = open(curdir + sep + self.path)
            self.send_response(200)
            self.send_header('Content-type','text/html')
            self.end_headers()
            self.wfile.write(f.read())
            f.close()
            return        
        if '/getdata' in self.path:
            target = open('./data.json', 'r')
            self.send_response(200)
            self.send_header('Content-type','application/json')
            self.end_headers()
            query_components = parse_qs(urlparse(target.read()).query)
            print(query_components)
            self.wfile.write(json.dumps(query_components))
            target.close()
            return

        if '/uninstall' in self.path:
            print(self.path)

            query_components = parse_qs(urlparse(self.path).query)

            if 'NeedLVM' not in query_components:
                return

            needLvm = query_components["NeedLVM"][0]
            lvmVol = query_components["LVMVolume"][0]
            yumUpd = query_components["YumUpdate"][0]
            domainName = query_components["DomainName"][0]
            cepFolder = query_components["CEPFolder"][0]
            gitlab = query_components["InstallGitlab"][0]
            cepUi = query_components["CEPUI"][0]
            cepMon = query_components["CEPMon"][0]
            grayLog = query_components["GrayLog"][0]

            cmd='no_proxy=localhost,127.0.0.1,registry.' + domainName + ' ANSIBLE_SCP_IF_SSH=y ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --flush-cache CEP_Uninstall.yml -i Inventory_CEP --extra-vars "CONFIRM=yes DomainName=' + domainName + ' DirectLVMstorage=' + needLvm + ' cepfolder=' + cepFolder + '"'
            print(cmd)
            self.send_response(200)
            self.send_header('Content-type','text/html')
            self.end_headers()
            self.wfile.write("<h1>Time for a coffee! Uninstalling CEP...Check console for progress!</h1>")
            self.wfile.write("<h3>Command that will be run:</h3>")
            self.wfile.write("<h4>" + cmd + "</h4>")
            for path in execute([cmd]):
                print(path, end="")
            return

        if '/install' in self.path:
            target = open('./data.json', 'w')
            target.truncate()
            target.write(self.path)
            target.close()
            query_components = parse_qs(urlparse(self.path).query)

            if 'NeedLVM' not in query_components:
                return
 
            needLvm = query_components["NeedLVM"][0]
            lvmVol = query_components["LVMVolume"][0]
            yumUpd = query_components["YumUpdate"][0]
            domainName = query_components["DomainName"][0]
            cepFolder = query_components["CEPFolder"][0]
            gitlab = query_components["InstallGitlab"][0]
            cepUi = query_components["CEPUI"][0]
            cepMon = query_components["CEPMon"][0]
            grayLog = query_components["GrayLog"][0]

            cmd='no_proxy=localhost,127.0.0.1,registry.' + domainName + ' ANSIBLE_SCP_IF_SSH=y ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP --extra-vars "YumUpdate=' + yumUpd + ' DomainName=' + domainName + ' cepfolder=' + cepFolder + ' InstallGitlab=' + gitlab +' cepUI=' + cepUi + ' cepmon=' + cepMon + ' cepGraylog=' + grayLog + ' DirectLVMstorage=' + needLvm + ' Docker_storage_devs=' + lvmVol + '"'
            print(cmd)
            self.send_response(200)
            self.send_header('Content-type','text/html')
            self.end_headers()
            self.wfile.write("<h1>Time for a coffee! Setting up CEP...Check console for progress!</h1>")
            self.wfile.write("<h3>Command that will be run:</h3>")
            self.wfile.write("<h4>" + cmd + "</h4>")
            for path in execute([cmd]):
                print(path, end="")
            return
        return

    except IOError:
        self.send_error(404,'File Not Found: %s' % self.path)


if __name__ == "__main__":
    try:
        server = HTTPServer(('0.0.0.0', 9090), MyHandler)
        print('Started http server at http://<this_host>:9090/index.html')
        server.serve_forever()
    except KeyboardInterrupt:
        print('^C received, shutting down server')
        server.socket.close()

