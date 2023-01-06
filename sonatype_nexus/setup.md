
# Install
```

Get PKG from Sonatype und extract to /opt


# Install Java
sudo yum install java-1.8.0-openjdk.x86_64 -y

# /opt/nexus-3.45.0-01/bin/nexus
INSTALL4J_JAVA_HOME_OVERRIDE=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.352.b08-2.el7_9.x86_64/jre/bin/java

# Open page
http://192.168.100.79:8081/
```



# create repo 
```
Create New docker hosted repo
HTTP: 8082
Allow annonymous login
Enable Docker V1 API
```

# Othe setup
```
Security realms --> Enable Docker Bearer Token
```