/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>

#define PLUGIN "New Plug-In"
#define VERSION "1.0"
#define AUTHOR "author"

#pragma semicolon 1
#pragma ctrlchar '\'

new timeleftbool;
new rsRound;
new match = 0;

/*ran at the beginning of each round*/
public plugin_init()
{
    /* intiating some plugin additives such as variables and what not.  I think they are somewhat straight forward */
    register_plugin("New Plug-In", "1.0", "mrsou");
    server_cmd("mp_chattime 5");
    register_clcmd("say", "startGame");
    register_cvar("currentRound", "1");
    new region[64];
    get_cvar_string("region", region, 63);
    register_cvar("region", region);
    new discordlink[64];
    get_cvar_string("discordlink", discordlink, 63);
    new hostname[64];
    get_cvar_string( "chostname", hostname, charsmax(hostname));
    register_cvar("discordlink", "TFPugs");
    register_cvar("round1Score", "0");
    register_cvar("chostname", "0");
    register_event("TeamScore", "get_teamscore", "a", "");
    register_cvar("team1score", "0");
    new cRound = get_cvar_num("currentRound");
    if (cRound == 1)
    {
        new mapname[32];
        get_mapname(mapname, 31);
        server_cmd("amx_nextmap %s", mapname);
	server_cmd("hostname \"%s %s %s R1\"",hostname, discordlink, region);
    }
    else if (cRound == 0){
	server_cmd("hostname \"%s %s %s\"", hostname, discordlink, region);
    }
    return 0;
}
        
/* function that will start the game with !rs */
public startGame(id)
{
    new hostname[64];
    get_cvar_string( "chostname", hostname, charsmax(hostname));
    new cRound = get_cvar_num("currentround");
    new szName[32];
    get_user_name(id, szName, charsmax(szName));
    /* This was suppose to check for admin, frankly, didnt work.. */
    if (!get_user_flags(id, 0) & 4)
    {
        return 0;
    }
    new buffer[256];
    new buffer1[33];
    new buffer2[33];
    read_argv(1, buffer, 255);
    parse(buffer, buffer1, 32, buffer2, 32);
   /* buffer1 is the first string before a space, in this case !rs .. the next condition checks of buffer1 and !rs are equal*/
   if (equali(buffer1, "!rs", 0))
    {
        log_message("%s has restarted the game", szName);
        /* if no map mentioned after !rs */
        if (equal(buffer2, "", 0))
        {
	   
            if (cRound == 1 || cRound == 0)
            {
                server_cmd("currentRound 1");
                new nextmap[32];
                get_cvar_string("amx_nextmap", nextmap, 31);
                server_cmd("changelevel %s", nextmap);
                new region[64];
                get_cvar_string("region", region, 63);
		  new discordlink[64];
                get_cvar_string("discordlink", discordlink, 63);
                server_cmd("hostname \"%s %s %s R1\"", hostname, discordlink, region); //these variables were created during plugin_init, they should actually be globals probably, but it seems to work as is
                rsRound = 1;
                return 0;
            }
            if (cRound == 2)
            {
                new Name[32];
                get_mapname(Name, 31);
                server_cmd("changelevel %s", Name);
                rsRound = 1;
                return 0;
            }
        }
	/* as of writing this comment, this should probably be else{ with th e below within it } */
        if (cRound == 1 || cRound == 0)
        {
            server_cmd("currentRound 1");
            new nextmap[32];
            get_cvar_string("amx_nextmap", nextmap, 31);
            server_cmd("changelevel %s", buffer2);
            new region[64];
            get_cvar_string("region", region, 63);
	   new discordlink[64];
            get_cvar_string("discordlink", discordlink, 63);
            server_cmd("hostname \"%s %s %s R1\"", hostname, discordlink, region);
            rsRound = 1;
            return 0;
        }
        if (cRound == 2)
        {
            new Name[32];
            get_mapname(Name, 31);
            server_cmd("changelevel %s", buffer2);
            rsRound = 1;
            return 0;
        }
        
    }
    return 0;
}

/*this runs at the end of the round*/
public plugin_end()
{
    new cRound = get_cvar_num("currentRound");
    if (!rsRound)
    {
        new score[64];
        get_cvar_string("team1score", score, 63);
        new hostname[64];
        get_cvar_string("chostname", hostname, 63);
        new region[64];
        get_cvar_string("region", region, 63);
        new discordlink[64];
        get_cvar_string("discordlink", discordlink, 63);
        new cRound = get_cvar_num("currentRound");
        if (cRound == 1)
        {
            server_cmd("hostname \"%s %s %s R2 - %s\"", hostname, discordlink, region, score);
            server_cmd("currentRound 2");
            server_cmd("round1Score %s", score);
        }
	/*This is the stuff discord bot is listening for to trigger stuff*/
        if (cRound == 2)
        {
	   //server_cmd("say Uploading Hampa Stats now!"); old command for bot to listen for..
		new t1Score = get_cvar_num("round1Score");
		new t2Score = get_cvar_num("team1Score");
		
		if(t1Score > t2Score){
			log_message("[MATCH RESULT] Team 1 Wins <%d> (%d) %s", t1Score, t2Score, region);
		}
		else if(t1Score < t2Score){
			log_message("[MATCH RESULT] Team 2 Wins <%d> (%d) %s", t2Score, t1Score, region);
		}
		else if(t1Score == t2Score){
			log_message("[MATCH RESULT] DRAW at (%d) %s", t1Score, region);
		}
		log_message("[GAMEND] RECORDING STATS]");
		server_cmd("hostname \"%s %s %s\"", hostname, discordlink, region);
		server_cmd("currentRound 0");
		server_cmd("round1Score 0");
	     
        }
    }
    rsRound = 0;
    return 0;
}

/*updates the team1score variable.. can also be updated in server if read wrong or in ghost cap*/
public get_teamscore()
{
    new team[32];
    read_data(1,team,31);
    new currentScore;
    if (!strcmp(team, "Blue") || !strcmp(team, "Blue :D?"))
    {
        currentScore = read_data(2);
        server_cmd("team1Score %d", currentScore);
    }
    return 0;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
