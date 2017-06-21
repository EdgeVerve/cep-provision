echo
echo  
echo "================================================"
echo "                INSTALLING CEP"
echo "================================================"
echo
echo
echo "Backing up cep.log to cep.log.1"
echo
mv cep.log cep.log.1 2> /dev/null
echo
echo "Opening port 9090 for this web-server"
firewall-cmd --zone=public --add-port=9090/tcp --permanent
echo
echo
python cep.py
