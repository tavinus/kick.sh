INSTDIR=/usr/bin
SH_FILE=kick.sh
INST_FILE=kick
INST_FILE_DIR=${INSTDIR}/${INST_FILE}

all: 

install:
	cp ${SH_FILE} ${INST_FILE_DIR}
	chmod 755 ${INST_FILE_DIR}

uninstall:
	rm ${INST_FILE_DIR}
