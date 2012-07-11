MG = {};
MG.api = {};  
MG.api.GameStatus = {};
MG.api.GameStatus.COMPLETE = true;



//MG.api.getDrawInfo - returns draw information
MG.api.getDrawInfo = function() {  
	var draws = [];
	
	draws[0] =  [{pickId:0, chances: 1, duplicable: false, range: [1,3,4,5,6,7,8,9,11]}]; 
	draws[1] =  [{pickId:1, chances: 2, duplicable: false, range: [7,8,9,11]}]; 
	draws[2] =  [{pickId:2, chances: 2, duplicable: false, range: [1,3,4,5,6,7,8,9,11]}];
	draws[3] =  [{pickId:3, chances: 2, duplicable: false, range: [1,3,5,6,7,8,9,11]}];
	draws[4] =  [{pickId:4, chances: 2, duplicable: false, range: [1,3,4,5,6,7,8,9,12]}];
	draws[5] =  [{pickId:5, chances: 2, duplicable: false, range: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]}];
	return draws;
}; 

//Note: all status code and status messages are going to change
//MG.api.setPick - pass it the picked value, sequence index where it goes and a pickId it belongs to 
//i.e. MG.api.setPick({pickId:0, seqId: 0; value:12});  
MG.api.setPick = (function(data){ 
	var duplicable = false,
	    chances = 1, 
	    pickId1 = 0, 
	    pickId2 = 1, 
	    pickId3 = 2, 
	    range = [],
	    picks = [],
	    complete = false,
	    __indexOf = Array.prototype.indexOf || function(item) {
		    for (var i = 0, l = this.length; i < l; i++) {
		      if (this[i] === item) return i;
		    }
		    return -1;
	   }, 
	   
	   picker = function(data) {  
			if(false || pickId1 !== data.pickId && pickId2 !== data.pickId && pickId3 !== data.pickId) { 
				return {
					statusCode: 1,
					statusDesc: 'Pick ID is not valid',
					returnData: {
						picks: picks[data.pickId],
						complete: complete
					}
				};
			} else if ( data.seqId < 0 ) {
				return {
					statusCode: 3,
					statusDesc: 'The sequence ID is off',
					returnData: {
						picks: picks[data.pickId],
						complete: complete
					}
				}; 
			}  else  { 
				if (!duplicable) { 
					if (__indexOf.call(picks[data.pickId], data.value) !== -1) {
						return  {
							statusCode: 4,
							statusDesc: 'The value  has been already selected.',
							returnData: {
								picks: picks[data.pickId],
								complete: complete
							}
						}; 
					}
				}
				picks[data.pickId][data.seqId] = data.value;
				complete = (function() {
						for(var i=picks.length-1; i>=0; i-=1)
							for(var j=picks[i].length-1; j>=0; j-=1)
								if(picks[i][j] === null) return false;
						return true;
					}());
					
				if(complete) {
					var data = {
							statusCode: 0,
							statusDesc: null,
							returnData: {
								picks: picks.splice(0), // diplicates the array
								complete: complete,
								ticketNumber: "123123123",
								drawNumber: "123123",
								playAmount: "2",
								drawTime: "12:32"
							}
						};
					
					complete = false;
					range[0] = [1,2,3,4,5,6,7,8,9,10,11,12];
			   	    picks[0] = [null, null, null];
					
					return data;
				}
				
				return {
					statusCode: 0,
					statusDesc: null,
					returnData: {
						picks: picks[data.pickId],
						complete: complete
					}
				};
			}  
		}; 

	    range[0] = [1,2,3,4,5,6,7,8,9,10,11,12]; 
	    
   	    picks[0] = [null, null, null,null, null];  
   	
	 	return picker;
	
})();
 
MG.api.setGameStatus = function(complete) {
	if (complete) {
		return 'Game is finished!';
	}
};