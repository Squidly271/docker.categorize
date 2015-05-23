#!/bin/bash

FILENAME=$1
shift
BETA=$1
shift
CATEGORIES=$@
echo "Source File: <strong>$FILENAME</strong>"
echo "Beta: <strong>$BETA</strong>"
echo "Categories: <strong>$CATEGORIES</strong>"

# Copy the template to a temp file

if [[ $FILENAME == "http"* ]]
then
	wget $FILENAME -O /tmp/docker.categorize.tmp
else
	cp $FILENAME /tmp/docker.categorize.tmp
fi

# force the last line to have a LF at the end

echo "" >> /tmp/docker.categorize.tmp

# Stage 1 - Search for (and remove) and existing category lines

rm /tmp/docker.categorize.tmp1 > /dev/null 2>&1

IFS=''
cat /tmp/docker.categorize.tmp | while read LINE
do
	if [[ $LINE == *"<Category>"* ]]
	then
		continue
	fi
	if [[ $LINE == *"<Beta>"* ]]
	then
		continue
	else
		echo $LINE >> /tmp/docker.categorize.tmp1
	fi
done

# Stage 2 - Add the new categories
XMLFILE="/boot/config/plugins/docker.categorize/templates/$(basename "$FILENAME" )"

rm /tmp/docker.categorize.xml.flag > /dev/null 2>&1

mkdir -p /boot/config/plugins/docker.categorize/templates

rm $XMLFILE > /dev/null 2>&1

cat /tmp/docker.categorize.tmp1 | while read LINE
do
	if [[ $LINE == *"<Container>"* ]]
	then
		echo $LINE >> $XMLFILE
		echo "  <Beta>$BETA</Beta>" >> $XMLFILE
		echo "  <Category>$CATEGORIES</Category>" >> $XMLFILE
		echo "" > /tmp/docker.categorize.xml.flag
	else
		echo $LINE >> $XMLFILE
	fi
done

if [ ! -e /tmp/docker.categorize.xml.flag ]
then
	echo "Not a valid XML template"
	exit
fi

echo
echo "Destination File: <strong>$XMLFILE</strong>"
rm /tmp/docker.categorize.tmp
rm /tmp/docker.categorize.tmp1
rm /tmp/docker.categorize.xml.flag > /dev/null 2>&1
