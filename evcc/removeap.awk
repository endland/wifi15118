BEGIN {
	maxlist = 0.00
	}



// {
	list = strtonum($1) 
	if(list >= 0.00){
		maxlist = list
	}
}

END {
	print maxlist
}
