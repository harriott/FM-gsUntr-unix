#!/bin/bash

# Joseph Harriott http://momentary.eu/ Fri 31 Oct 2014

# Prepare Untracked files for committing to a unix-only Git repository.

# The default action is to go ahead and convert the selected files to unix,
# but this script optionally takes a single argument:
#   If the argument is given, don't go ahead with the conversion,
#     but instead open vim on the selected files for further inspection,
#   except where the argument is 'd', in which case go ahead with a conversion to dos.
# If no argument and not in a Git repository ask what to do.

tstmptempf=${BASH_SOURCE[0]}
tstmptempf=${tstmptempf#./}
tstmptempf="${tstmptempf%.*}-$(date +%Y%m%d%H%M%S).txt"
if [ -d ".git" ]; then
	echo "Creating temp list of CRLF'd Git Unstracked's in $tstmptempf :"
	git status -u | grep "$(echo -ne \\t)" | sed 's#\t\(modified:   \)*##' |
		xargs -i{} grep -Ul $'\015' {} > $tstmptempf
		# - that last grep will snag on any U000Ds
else
	echo "No Git here, so just grabbing this directory's text files list:"
	ls *.txt > $tstmptempf
fi
cat $tstmptempf
# Assume we're converting to unix (the raison d'être):
endff="unix"
# Doubt: further inspection of the files is wanted:
silentorvim="v"
if [ -z "$1" ]; then
	# there was no argument - odds are that we're going ahead with the conversion:
	silentorvim="s"
	# but doubt again if Git's not there - ask:
	if [ ! -d ".git" ]; then
		read -p "s = to go ahead silently, anything else to just enter vim: " silentorvim
		if [ -z "$silentorvim" ]; then silentorvim="v"; fi
	fi
elif [ $1 = "d" ]; then
	# the argument was 'd' so a dos conversion will be done:
	endff="dos"
	silentorvim="s"
fi
if [ -s $tstmptempf ]; then
	if [ $silentorvim = "s" ]; then
		vim -c "silent argdo w ++ff=$endff" -c wqa $(cat $tstmptempf)
		echo "- all changed to $endff file format."
	else
		vim -o $(cat $tstmptempf)
		echo "- files were inspected by you in Vim."
	fi
else
	# - the file list was empty:
	echo "- no suitable files were found."
fi
rm $tstmptempf
