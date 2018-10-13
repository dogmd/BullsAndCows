.data
	words: .asciiz "HAVEWITHTHISTHEYFROMWHATMAKEKNOWTIMEYEARWHENTHEMSOMETAKEINTOJUSTYOURCOMETHANLIKETHENMOREWANTALSOMOREFINDGIVEMANYONLYVERYBACKLIFEWORKDOWNOVERLASTWHENMOSTMUCHMEANSAMEHELPTALKTURNHANDSHOWPARTOVERSUCHCASEMOSTEACHHEARWORKPLAYMOVELIKELIVEHOLDNEXTMUSTHOMEFACTWORDSIDEKINDFOURHEADLONGBOTHLONGHOURGAMELINELOSECITYMUCHNAMEFIVEONCEREALTEAMBESTIDEABODYLEADBACKONLYFACEREADSURESUCHGROWOPENWALKGIRLBOTHABLELOVEWAITSENDHOMESTAYPLANYEAHCARELATEHARDROLERATEDRUGSHOWWIFEMINDHOPEVIEWTOWNROADTRUEJOINPICKWEARFORMSITEBASESTARHALFEASYCOSTFACELANDNEWSLOVEOPENSTEPTYPEDRAWFILMHAIRTERMRULERISKFIREBANKWESTRESTDEALPASTGOALDROPPLANUPONPUSHNOTEFINENEARPAGETHANRACEEACHRISEEASTSAVETHUSSIZEFUNDSIGNLISTHARDLEFTDEALFAILNAMESORTBLUESONGDARKHANGROCKNOTEHELPCOLDFORMMAINCARDSEATNICEFIRMCAREHUGETALKHEADBASEPAINPLAYWIDEFISHTRIPUNITBESTPASTFEARSIGNHEATSINGWHOMSKINDOWNITEMSTEPYARDBEATTENDTASKSHOTWISHSAFERICHVOTEBORNWINDFASTCOSTLIKEBIRDHURTHOPEVOTETURNONCECAMPDATEVERYHOLESHIPPARKSPOTLACKBOATGAINHIDEGOLDCLUBFARMBANDRIDEWILDEARNTINYPATHSHOPFOLKLIFTJUMPWARMSOFTGIFTPASTWAVEMOVEDENYSUITBLOWKINDBURNSHOEVIEWBONEWINEMEANFIRETOURGRABFAIRPAIRTAPEHIRENEXTLADYNECKLEANHATEMALEARMYSHUTLOTSRAINFUELLEAFLEADSALTSOULBEARTHINHALFOKAYCODEJURYDESKFEARLIKELASTRINGMARKLOANCREWMALEMEALCASHLINKNOSEFILESICKDUTYSLOWZONEWAKEWARNSNOWSLIPMEATSOILLATEGOLFJUSTUSERPARTUSEDBOWLLONGHOSTRELYBACKDEBTTANKBONDFILEWINGMEANPOURSTIRTEARHERORESTBUSYCOPYCITEGRAYDISHCORERUSHRISEVASTLACKFLOWTONEAIDSGATEHANDLANDMILKCASTRIDELIVEPLUSMINDWEAKLISTWRAPMARKDRAGDIETWASHPOSTDARKCHIPSELFBIKESLOWLINKLAKEBENDGAINARABWALKSANDRULELOCKTEARPOSESALEMINETALEJOKECOATURGEDUSTGLADPACKIRONSUREKINGBEANPEAKVARYWIREHOLYRINGTWINSTOPLUCKRACEBURYPRAYPUREBELTFLAGCORNCROPLINEDATEPINKBUCKPOEMBINDMAILTUBEQUITJAILPACECAKEMINEDROPFASTPACKFLATWAGESNAPGEARWAVESPINRANKBEATWINDLOSTLIKEBEARPANTWIPEPORTDIRTRICEFLOWDECKPOLEMODEBAKESINKSWIMTIREHOLDFADESPOTMASKEASYLOADFATEOVENPOETPALELOADLAWNPLOTMATHTAILPALMSOUPPILEFUNDAIDEMYTHMENURATELOUDAUTOBITEPINERISKCHEFSUITSHITCOPEHOSTWISEACIDLUNGFIRMUGLYROPESAKEGAZECLUEDEARCOALSIGHDAREOKAYROSERAILRANKNORMSTEMRAPEHUNTECHOBARERENTSHOPEVILSLAMMELTPARKCOLDFOLDDUCKDOSETRAPLENSLENDNAILCAVEHERBWISHWARMLASTSUCKLEAPPASTPONDDUMPLIMBTUNEHARMHORNBLUEGRIPBEAMRUSHFORKDISKLOCKBLOWEXITSHIPMILDAMIDLOUDHERSBITEEVILORALFISTBATHBOLDTUNEHINTFLIPBIASLAMPCHINARABCHOPSILKRAGEWAKEDAWNTIDESEALSINKTRAPSCANCARTSTEMMATESLAPOURSHEATBARNTUCKDRUMPOSTSAILNESTNEARLANECAGERACKWOLFGRINSEALAUNTROCKRENTCALMHAULRUINBUSHCLIPEXAMSTAREDITWHIPBOILPORKSOCKNEARJUMPSEXYSEATLIONCASTCORDHARMSORTSOAPCUTESHEDICONHEALCOINSTAYDAMNCASEGAZEHIKESACKTRAYCOUPSKIPSOLEJOKEPILECURECUREFAMEATOPTHISGRINRAINCHEWDUMBBULKGOATNEATPARTPOKESOARCALMCLAYFAREDISCSOFAFISHSOAKSLOTRIOTTILEPLEACOPYBOLTDOCKTRIMSPIT"
	numWords: .word 673
	inputPrompt: .asciiz "Enter your guess (STOP to give up): "
	inputBuffer: .space 5
	giveUpOutput: .asciiz "\nYou gave up! The word was: "
.text
	lw	$a1, numWords		# Upperbound for random number generation
	li	$v0, 42			# Syscall for generating random number
	syscall				# Generate random number, stored in $a0
	sll	$a0, $a0, 2		# Multiply by 4 because each word is 4 bytes long
	la	$t0, words		# $t0 contains start address of words data segment
	add	$a0, $t0, $a0		# Add word offset to make $a0 store position of start of word
	jal	loadFourBytes		# Load the word starting at $a0 (this is necessary instead of lw because the word may not start at a word boundary)
	move	$s0, $v0		# Store string into $s0
					# At this point, the only register that needs to stay the same is $s0, which stores the word that was retrieved from the list of words
	li	$v0, 30			# Get system time
	syscall				# Start timer
	move	$s2, $a0		# Store start time in $s2
	li 	$v0, 4			# Syscall for printing string
	la 	$a0, inputPrompt	# Load the string to be printed into $a0
	syscall				# Print string
	li 	$v0, 8			# Syscall for reading string
	la 	$a0, inputBuffer	# $a0 will store the address that the input is stored at
	li 	$a1, 5			# Read 4 characters (1 for null terminator)
	syscall				# Read the string, $a0 stores address of input		
	
	jal	loadFourBytes		# Load the word starting at $a0 (this is necessary instead of lw because the word may not start at a word boundary)
	move	$s1, $v0		# Store string into $s1

	li	$t0, 0x53544F50		# $t0 will contain "STOP"
	beq	$t0, $s1, giveUp
	li	$v0, 10
	syscall
	
printWord:				# $a0 should contain string to be printed
	li	$t0, 0xFF000000		# Mask for getting characters
	li	$t1, 24			# Number of bits to shift to (to get first byte)
	move	$t3, $a0		# Store a copy of $a0 in $t3
printChar:
	and	$a0, $t3, $t0		# Extract char into $a0
	srlv	$a0, $a0, $t1		# Move char into first byte
	srl	$t0, $t0, 8		# Move on to next char
	subi	$t1, $t1, 8		# Move on to next char
	li	$v0, 11			# Syscall for printing char
	syscall				# Print extracted char
	bne	$t0, $zero, printChar	# Repeat for every char
	jr	$ra

					# This function takes an address, and adds 4 bytes starting at that address to $v0, in reverse order
loadFourBytes:				# $a0 should contain the base address, $v0 will contain the word that was loaded.
	li	$t0, 4			# $t0 will be the counter to make sure this only runs 4 times
	li	$v0, 0			# Reset $v0
loadByte:
	sll	$v0, $v0, 8		# Move on to next byte
	lbu	$t1, ($a0)		# Store byte into $t1
	or	$v0, $v0, $t1		# Write byte into $v0
	addi	$a0, $a0, 1		# Move on to next byte
	subi	$t0, $t0, 1		# Keep track of how many bytes are left
	bne	$t0, $zero, loadByte	# Load all 4 bytes
	jr	$ra
	
giveUp:
	la	$a0, giveUpOutput	# Print giveUpOutput
	li	$v0, 4			# Print string syscall
	syscall				# Print string
	move	$a0, $s0		# Get $s0 ready for printing
	jal	printWord		# Print $s0