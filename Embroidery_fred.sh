#!/bin/bash
#
# Developed by Fred Weinhaus 8/20/2015 .......... revised 5/11/2016
#
# ------------------------------------------------------------------------------
#
# Licensing:
#
# Copyright © Fred Weinhaus
#
# My scripts are available free of charge for non-commercial use, ONLY.
#
# For use of my scripts in commercial (for-profit) environments or
# non-free applications, please contact me (Fred Weinhaus) for
# licensing arrangements. My email address is fmw at alink dot net.
#
# If you: 1) redistribute, 2) incorporate any of these scripts into other
# free applications or 3) reprogram them in another scripting language,
# then you must contact me for permission, especially if the result might
# be used in a commercial or for-profit environment.
#
# My scripts are also subject, in a subordinate manner, to the ImageMagick
# license, which can be found at: http://www.imagemagick.org/script/license.php
#
# ------------------------------------------------------------------------------
#
####
#
# USAGE: embroidery [-n numcolors ] [-p pattern] [-t thickness] [-g graylimit]
# [-f fuzzval] [-b bgcolor] [-a angle] [-r range] [-i intensity] [-e extent]
# [-B bevel] [-A azimuth] [-E elevation] [-C contrast] [-S spread]
# [-N newseed] [-M mix] infile outfile
#
# USAGE: embroidery [-h or -help]
#
# OPTIONS:
#
# -n     numcolors     number of desired or actual colors in image; integer>0;
#                      default=8
# -p     pattern       weave pattern; choices are either linear (1) or
#                      crosshatch (2); default=linear
# -t     thickness     weave thickness; integer>=1; default=2
# -g     graylimit     limit colors near black and near white to
#                      gray(graylimit%) and gray(100%-graylimit%);
#                      0<=integer<=100; default=20
# -f     fuzzval       fuzz value for recoloring near black and near white;
#                      0<=integer<=100; default=20
# -b     bgcolor       actual background color in image; default is most the
#                      frequent color
# -a     angle         initial pattern angle for background color;
#                      -360<=integer<=360; default=0
# -r     range         range of pattern angles; 0<=integer<=360; default=90
# -i     intensity     shadow intensity; higher is darker; 0 is no shadow;
#                      0<=integer<=100; default=25
# -e     extent        shadow extent; integer>=0; 0 is no shadow; default=2
# -B     bevel         pattern bevel amount; integer>=0; default=4
# -A     azimuth       bevel azimuth angle; -360<=integer<=360; default=130
# -E     elevation     bevel elevation angle; 0<=integer<=90; default=30
# -C     contrast      bevel sigmoidal-contrast amount; float>=0;
#                      default=0 (no added contrast)
# -S     spread        pattern spread (diffusion); integer>=0; default=1
# -N     newseed       pattern new seed value; integer>=0;
#                      default is random seed value
# -M     mix           mixing between before and after spread result;
#                      0<=integer<=100; 100 is all spread; 0 is no spread;
#                      default=100
#
###
#
# NAME: EMBROIDERY
#
# PURPOSE: To apply an embroidery effect to each color in an image.
#
# DESCRIPTION: EMBROIDERY applies an embroidery effect to each color in an
# image. The image must have limited number of colors or only the top most
# frequent colors will be used. Each color will get the same pattern, but at
# different rotation angles.
#
# Arguments:
#
# -n numcolors ... NUMCOLORS is the number of desired or actual colors in the
# image. Values are integers>0. The default=8.
#
# -p pattern ... PATTERN is the weave pattern. The choices are either
# linear (1) or crosshatch (2). The default=linear.
#
# -t thickness ... THICKNESS is the weave thickness. Values are integers>=1.
# The default=2.
#
# -g graylimit ... GRAYLIMIT limits (converts) the colors near black and
# near white to gray(graylimit%) and gray(100%-graylimit%). Values are
# 0<=integers<=100. The default=20.
#
# -f fuzzval ... FUZZVAL is the fuzz value used for recoloring near black and
# near white. Values are 0<=integers<=100. The default=20.
#
# -b bgcolor ... BGCOLOR is the actual background color in the image. The
# default is most the frequent color.
#
# -a angle ... ANGLE is the initial pattern angle used for the background
# color. Values are -360<=integers<=360. The default=0 (horizontal)
#
# -r range ... RANGE is the range of pattern angles over all the colors.
# Values are 0<=integers<=360. The default=90 (deg).
#
# -i intensity ... INTENSITY is the shadow intensity. Higher is darker.
# 0 is no shadow. Values are 0<=integers<=100. The default=25.
#
# -e extent ... EXTENT is the shadow extent in pixels. Values are integers>=0.
# 0 is no shadow. The default=2.
#
# -B bevel ... BEVEL is the pattern bevel amount. Values are integers>=0.
# The default=4.
#
# -A azimuth ... AZIMUTH is the bevel azimuth angle. Values are
# -360<=integers<=360. The default=130.
#
# -E elevation ... ELEVATION is the bevel elevation angle. Values are
# 0<=integers<=90. The default=30.
#
# -C contrast ... CONTRAST is the bevel sigmoidal-contrast amount. Values are
# floats>=0. The default=0 (no added contrast)
#
# -S spread ... SPREAD is the pattern spread (diffusion). Values are
# integers>=0. The default=1.
#
# -N newseed ... NEWSEED is the pattern (new) seed value. Values are
# integers>=0. The default is a random seed value.
#
# -M mix ... MIX is the mixing of the before and after spread result. Values
# are 0<=integers<=100. 100 is all spread. 0 is no spread. The default=100
#
# CAVEAT: No guarantee that this script will work on all platforms,
# nor that trapping of inconsistent parameters is complete and
# foolproof. Use At Your Own Risk.
#
######
#

# set default values
numcolors=2			# number of desired or actual colors in image; integer>0; default=8
pattern="linear"	# weave pattern; linear or crosshatch
thickness=2			# weave thickness; integer>=1; default=2
graylimit=20		# limit near black and near white to gray(graylimit%) and gray(100%-graylimit%); 0<=integer<=100; default=20
fuzzval=20			# fuzz value for recoloring near black and near white; 0<=integer<=100; default=20
bgcolor=""			# background color in image; default is most frequent color
angle=0				# initial angle of background color; -360<=integer<=360
range=90			# range of angles; 0<=integer<=360; default=90
intensity=25		# shadow intensity; higher is darker; 0 is no shadow; 0<=integer<=100; default=25
extent=2			# shadow extent; integer>=0; 0 is no shadow; default=2
bevel=4				# pattern bevel amount; integer>=0; default=4
azimuth=130			# bevel azimuth angle; -360<=integer<=360; default=130
elevation=30		# bevel elevation angle; 0<=integer<=90; default=30
contrast=0			# bevel sigmoidal-contrast amount; integer>=0; default=0 (no added contrast)
spread=1			# pattern spread; integer>=0; default=1
newseed=""			# pattern new seed value; integer>=0; default is random value
mix=100				# mixing between before and after spread result; 0<=integer<=100; 100 is all spread; 0 is no spread; default=100

# set directory for temporary files
tmpdir="."    # suggestions are dir="." or dir="/tmp"

dir="$tmpdir/EMBROIDERY.$$"

# set up functions to report Usage and Usage with Description
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
usage1()
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^###/g;  /^#/!q;  s/^#//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}
usage2()
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^######/g;  /^#/!q;  s/^#*//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}

# function to report error messages
errMsg()
	{
	echo ""
	echo $1
	echo ""
	usage1
	exit 1
	}

# function to test for minus at start of value of second part of option 1 or 2
checkMinus()
	{
	test=`echo "$1" | grep -c '^-.*$'`   # returns 1 if match; 0 otherwise
    [ $test -eq 1 ] && errMsg "$errorMsg"
	}

# test for correct number of arguments and get values
if [ $# -eq 0 ]
	then
	# help information
	echo ""
	usage2
	exit 0
elif [ $# -gt 36 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
		# get parameters
		case "$1" in
	  -h|-help)    # help information
				   echo ""
				   usage2
				   ;;
			-n)    # get numcolors
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID NUMCOLORS SPECIFICATION ---"
				   checkMinus "$1"
				   numcolors=`expr "$1" : '\([0-9]*\)'`
				   [ "$numcolors" = "" ] && errMsg "--- NUMCOLORS=$numcolors MUST BE AN INTEGER ---"
				   test1=`echo "$numcolors <= 0" | bc`
				   [ $test1 -eq 1 ] && errMsg "--- NUMCOLORS=$numcolors MUST BE AN INTEGER GREATER THAN 0 ---"
				   ;;
			-p)    # get  pattern
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID PATTERN SPECIFICATION ---"
				   checkMinus "$1"
				   pattern=`echo "$1" | tr '[A-Z]' '[a-z]'`
				   case "$pattern" in
						linear|1) pattern="linear" ;;
						crosshatch|2) pattern="crosshatch" ;;
						*) errMsg "--- PATTERN=$pattern IS AN INVALID VALUE ---"  ;;
				   esac
				   ;;
			-t)    # get thickness
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID THICKNESS SPECIFICATION ---"
				   checkMinus "$1"
				   thickness=`expr "$1" : '\([0-9]*\)'`
				   [ "$thickness" = "" ] && errMsg "--- THICKNESS=$thickness MUST BE AN INTEGER ---"
				   test1=`echo "$thickness < 2" | bc`
				   [ $test1 -eq 1 ] && errMsg "--- THICKNESS=$thickness MUST BE AN INTEGER GREATER THAN 1 ---"
				   ;;
			-g)    # get graylimit
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID GRAYLIMIT SPECIFICATION ---"
				   checkMinus "$1"
				   graylimit=`expr "$1" : '\([0-9]*\)'`
				   [ "$graylimit" = "" ] && errMsg "--- GRAYLIMIT=$graylimit MUST BE AN INTEGER ---"
				   test1=`echo "$graylimit < 0" | bc`
				   test2=`echo "$graylimit > 100" | bc`
				   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- GRAYLIMIT=$graylimit MUST BE AN INTEGER BETWEEN 0 AND 100 ---"
				   ;;
			-f)    # get fuzzval
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID FUZZVAL SPECIFICATION ---"
				   checkMinus "$1"
				   fuzzval=`expr "$1" : '\([0-9]*\)'`
				   [ "$fuzzval" = "" ] && errMsg "--- FUZZVAL=$fuzzval MUST BE AN INTEGER ---"
				   test1=`echo "$fuzzval < 0" | bc`
				   test2=`echo "$fuzzval > 100" | bc`
				   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- FUZZVAL=$fuzzval MUST BE AN INTEGER BETWEEN 0 AND 100 ---"
				   ;;
			-b)    # get bgcolor
				   shift  # to get the next parameter - color
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID BGCOLOR SPECIFICATION ---"
				   checkMinus "$1"
				   bgcolor="$1"
				   ;;
			-a)    # get angle
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   #errorMsg="--- INVALID ANGLE SPECIFICATION ---"
				   #checkMinus "$1"
				   angle=`expr "$1" : '\([-0-9]*\)'`
				   [ "$angle" = "" ] && errMsg "--- ANGLE=$angle MUST BE AN INTEGER ---"
				   test1=`echo "$angle < -360" | bc`
				   test2=`echo "$angle > 360" | bc`
				   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- ANGLE=$angle MUST BE AN INTEGER BETWEEN -360 AND 360 ---"
				   ;;
			-r)    # get range
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID RANGE SPECIFICATION ---"
				   checkMinus "$1"
				   range=`expr "$1" : '\([0-9]*\)'`
				   [ "$range" = "" ] && errMsg "--- RANGE=$range MUST BE AN INTEGER ---"
				   test1=`echo "$range < 0" | bc`
				   test2=`echo "$range > 360" | bc`
				   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- RANGE=$range MUST BE AN INTEGER BETWEEN 0 AND 360 ---"
				   ;;
			-i)    # get intensity
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID INTENSITY SPECIFICATION ---"
				   checkMinus "$1"
				   intensity=`expr "$1" : '\([0-9]*\)'`
				   [ "$intensity" = "" ] && errMsg "--- INTENSITY=$intensity MUST BE AN INTEGER ---"
				   test1=`echo "$intensity < 0" | bc`
				   test2=`echo "$intensity > 100" | bc`
				   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- INTENSITY=$intensity MUST BE AN INTEGER BETWEEN 0 AND 100 ---"
				   ;;
			-e)    # get extent
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID EXTENT SPECIFICATION ---"
				   checkMinus "$1"
				   extent=`expr "$1" : '\([0-9]*\)'`
				   [ "$extent" = "" ] && errMsg "--- EXTENT=$extent MUST BE A NON-NEGATIVE INTEGER ---"
				   ;;
			-B)    # get bevel
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID BEVEL SPECIFICATION ---"
				   checkMinus "$1"
				   bevel=`expr "$1" : '\([0-9]*\)'`
				   [ "$bevel" = "" ] && errMsg "--- BEVEL=$bevel MUST BE A NON-NEGATIVE INTEGER ---"
				   ;;
			-A)    # get azimuth
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   #errorMsg="--- INVALID AZIMUTH SPECIFICATION ---"
				   #checkMinus "$1"
				   azimuth=`expr "$1" : '\([-0-9]*\)'`
				   [ "$azimuth" = "" ] && errMsg "--- AZIMUTH=$azimuth MUST BE AN INTEGER ---"
				   test1=`echo "$azimuth < -360" | bc`
				   test2=`echo "$azimuth > 360" | bc`
				   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- AZIMUTH=$azimuth MUST BE AN INTEGER BETWEEN -360 AND 360 ---"
				   ;;
			-E)    # get elevation
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID ELEVATION SPECIFICATION ---"
				   checkMinus "$1"
				   elevation=`expr "$1" : '\([0-9]*\)'`
				   [ "$elevation" = "" ] && errMsg "--- ELEVATION=$elevation MUST BE AN INTEGER ---"
				   test1=`echo "$elevation < 0" | bc`
				   test2=`echo "$elevation > 90" | bc`
				   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- ELEVATION=$elevation MUST BE AN INTEGER BETWEEN 0 AND 100 ---"
				   ;;
			-C)    # get contrast
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID CONTAST SPECIFICATION ---"
				   checkMinus "$1"
				   contrast=`expr "$1" : '\([.0-9]*\)'`
				   [ "$contrast" = "" ] && errMsg "--- CONTAST=$contrast MUST BE A NON-NEGATIVE FLOAT ---"
				   ;;
			-S)    # get spread
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID SPREAD SPECIFICATION ---"
				   checkMinus "$1"
				   spread=`expr "$1" : '\([0-9]*\)'`
				   [ "$spread" = "" ] && errMsg "--- SPREAD=$spread MUST BE A NON-NEGATIVE INTEGER ---"
				   ;;
			-N)    # get newseed
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID NEWSEED SPECIFICATION ---"
				   checkMinus "$1"
				   newseed=`expr "$1" : '\([0-9]*\)'`
				   [ "$newseed" = "" ] && errMsg "--- NEWSEED=$newseed MUST BE A NON-NEGATIVE INTEGER ---"
				   ;;
			-M)    # get mix
				   shift  # to get the next parameter
				   # test if parameter starts with minus sign
				   errorMsg="--- INVALID MIX SPECIFICATION ---"
				   checkMinus "$1"
				   mix=`expr "$1" : '\([0-9]*\)'`
				   [ "$mix" = "" ] && errMsg "--- MIX=$mix MUST BE AN INTEGER ---"
				   test1=`echo "$mix < 0" | bc`
				   test2=`echo "$mix > 100" | bc`
				   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- MIX=$mix MUST BE AN INTEGER BETWEEN 0 AND 100 ---"
				   ;;
			 -)    # STDIN and end of arguments
				   break
				   ;;
			-*)    # any other - argument
				   errMsg "--- UNKNOWN OPTION ---"
				   ;;
			*)     # end of arguments
				   break
				   ;;
		esac
		shift   # next option
	done
	# get infile and outfile
	infile="$1"
	outfile="$2"
fi

# test that infile provided
[ "$infile" = "" ] && errMsg "--- NO INPUT FILE SPECIFIED ---"

# test that outfile provided
[ "$outfile" = "" ] && errMsg "--- NO OUTPUT FILE SPECIFIED ---"

mkdir "$dir" || errMsg "--- FAILED TO CREATE TEMPORARY FILE DIRECTORY ---"
trap "rm -rf $dir; exit 0" 0
trap "rm -rf $dir; exit 1" 1 2 3 15

# read the input image into the temporary cached image and test if valid
convert -quiet "$infile" +repage -depth 8 "$dir/tmpI.mpc" ||
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO size  ---"


# get image dimensions
ww=`convert -ping $dir/tmpI.mpc -format "%w" info:`
hh=`convert -ping $dir/tmpI.mpc -format "%h" info:`

ww2=$((2*ww))
hh2=$((2*hh))

# get numcolors most frequently used colors
colorArr=(`convert $dir/tmpI.mpc -format "%c" histogram:info: |\
sort -k 1 -nr | head -n $numcolors | sed -n "s/^.*\(#.*\) .*$/\1/p"`)
#echo "${colorArr[*]}"
#echo "${#colorArr[*]}"

# create color map
convert -size 1x1 xc:"${colorArr[0]}" $dir/tmpL.mpc
if [ $numcolors -gt 1 ]; then
	for ((i=1; i<numcolors; i++)); do
		convert $dir/tmpL.mpc \( -size 1x1 xc:"${colorArr[$i]}" \) +append $dir/tmpL.mpc
	done
fi

# remap colors
convert $dir/tmpI.mpc +dither -remap $dir/tmpL.mpc $dir/tmpI.mpc

# set up for bgcolor
if [ "$bgcolor" = "" ]; then
	bgcolor="${colorArr[0]}"
else
	bgcolor=`convert xc:"$bgcolor" -depth 8 txt:- | tail -n +2 | tr -cs "#0-9ABCDEF" " " | cut -d\  -f6`
fi


# do embroidery for each color at a different angle

# set up ang and anginc
anginc=`convert xc: -format "%[fx:$range/$numcolors]" info:`
if [ "$pattern" = "linear" ]; then
	ang=`convert xc: -format "%[fx:-45+$angle]" info:`
elif [ "$pattern" = "crosshatch" ]; then
	ang=`convert xc: -format "%[fx:-90+$angle]" info:`
fi
#echo "ang=$ang"

# set up for newseed
if [ "$newseed" != "" ]; then
	seeding="-seed $newseed"
else
	seeding=""
fi

# set up for spreading
if [ $spread -eq 0 ]; then
	sproc=""
	mproc=""
else
	sproc="-clone 0 $seeding -spread $spread"
	mproc="-define compose:args=$mix -compose blend -composite"
fi

# create tiled pattern image
if [ "$pattern" = "linear" ]; then
	thick1=$thickness
	thick2=$((2*thick1))
	thick3=$((3*thick1))
	fullthick=$((4*thick1))
	convert -size ${thickness}x${fullthick} gradient: -rotate 270 \
	\( -clone 0 -roll +${thick1}+0 \) \( -clone 0 -roll +${thick2}+0 \) \( -clone 0 -roll +${thick3}+0 \) -append \
	-write mpr:tile +delete -size ${ww2}x${hh2} tile:mpr:tile \
	\( $sproc \) \
	$mproc \
	$dir/tmpP.mpc
elif [ "$pattern" = "crosshatch" ]; then
	thick1=$(($thickness+3))
	convert -size ${thick1}x${thick1} gradient: -rotate 270 \
	\( -clone 0 -flop \)  -append \
	-write mpr:tile +delete -size ${ww2}x${hh2} tile:mpr:tile \
	\( $sproc \) \
	$mproc \
	$dir/tmpP.mpc
fi
#echo "thick1=$thick1; thick2=$thick2; thick3=$thick3; fullthick=$fullthick;"


# modify input image for near white and near black to gray($whitept%) and "gray($blackpt%)"
# if graylimit != 0 and fuzzval=0, then only exactly black and exactly white will be recolored
# if graylimit = 0 and fuzzval != 0, then any color close to white and black will become exactly white and exactly black
# if graylimit = 0 and fuzzval = 0, then nothing changes, so do not do processing
if [ "$graylimit" = "0" -a "$fuzzval" = "0" ]; then
	convert $dir/tmpI.mpc $dir/tmpR.mpc
else
	blackpt=$graylimit
	whitept=$((100-graylimit))
	convert $dir/tmpI.mpc -fuzz $fuzzval% -fill "gray($whitept%)" -opaque white -fill "gray($blackpt%)" -opaque black $dir/tmpR.mpc
fi

# rotate tile pattern and composite and and make all other color regions transparent
# note in the bevel section, need to add -alpha deactivate ... -alpha on for IM 7, since IM 7 does not persist the alpha automatically as in IM 6.
# but including it does not affect IM 6 whether it is there or not
for ((j=0; j<numcolors; j++)); do
	if [ "${colorArr[$j]}" = "$bgcolor" -o $bevel -eq 0 ]; then
		convert $dir/tmpR.mpc \
		\( $dir/tmpI.mpc +transparent "${colorArr[$j]}" -alpha extract \) \
		\( $dir/tmpP.mpc -rotate $ang +repage -gravity center -crop ${ww}x${hh}+0+0 +repage \) \
		\( -clone 0 -clone 2 -compose softlight -composite \) \
		-delete 0,2 +swap -compose over -alpha off -compose copy_opacity -composite \
		\
		\( -clone 0 -background black -shadow ${intensity}x${extent}+0+0 -channel A -level 0,50% +channel \) \
		+swap +repage -gravity center -compose over -composite \
		$dir/tmpI_$j.mpc
		ang=`convert xc: -format "%[fx:$ang+$anginc]" info:`
	else
		convert $dir/tmpR.mpc \
		\( $dir/tmpI.mpc +transparent "${colorArr[$j]}" -alpha extract \) \
		\( $dir/tmpP.mpc -rotate $ang +repage -gravity center -crop ${ww}x${hh}+0+0 +repage \) \
		\( -clone 0 -clone 2 -compose softlight -composite \) \
		-delete 0,2 +swap -compose over -alpha off -compose copy_opacity -composite \
		\
		\( +clone -alpha extract -write mpr:alpha -blur 0x$bevel -shade ${azimuth}x${elevation} \
			mpr:alpha -alpha off -compose copy_opacity -composite -alpha on -alpha background \
			-alpha deactivate -auto-level -function polynomial 3.5,-5.05,2.05,0.25 -sigmoidal-contrast ${contrast}x50% -alpha on \) \
		-compose over -compose Hardlight -composite \
		\
		\( -clone 0 -background black -shadow ${intensity}x${extent}+0+0 -channel A -level 0,50% +channel \) \
		+swap +repage -gravity center -compose over -composite \
		$dir/tmpI_$j.mpc
		ang=`convert xc: -format "%[fx:$ang+$anginc]" info:`
	fi
done

imagelist=""
for ((k=0; k<numcolors; k++)); do
	imagelist="$imagelist $dir/tmpI_$k.mpc"
done

# flatten images
convert $imagelist -background none -flatten -gravity center -crop ${ww}x${hh}+0+0 +repage "$outfile"


exit 0
