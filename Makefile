include config

TAG = admiraledu

ENV = -e ClientID=$(ClientID) \
	-e ClientSecret=$(ClientSecret) \
	-e RedirectUri=$(RedirectUri) \
	-e BaseUrl=$(BaseUrl) \
	-e CryptoPassphrase=$(CryptoPassphrase) \
	-e AdminEmail=$(AdminEmail) \
	-e ClassName=$(ClassName)

all:
	docker build -t $(TAG) .

run: all
	docker run -i -t --rm -p 80:80 $(ENV) $(TAG)

bash: all
	docker run -i -t --rm -p 80:80 $(ENV) $(TAG) /bin/bash

debug: all
	docker run -i -t --rm -p 80:80 $(ENV) $(TAG) ./debug.sh
