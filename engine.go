// to do

// Register Account (Done)
// Create subreddit (Done)
// Join subreddit (Done) added check for duplicate entries during simulation
// Leave subreddit (Done) added check to verify if the pair exists
// Post in subreddit
// Comment in subreddit
// 	Hierarchial view
// Upvote, Downvote, compute Karma
// get feed of posts
// get lists of direct messages; reply to direct messages

// implement simulator
// 	simulate as many users as you can (10 at start)
// 	simulate periods of live connection and disconnection for users
// 	simulate a zipf ditribution on the number of sub-reddit members.
// 		for account with a lot of subscribers, increase the number of posts.
// 		Make some of these messages re-posts

// compute karma
// for each upvote/downvote receoived +/-1
// for each new post +5 karma


package main

import (
	"fmt"
	"time"
	"log"
	"math/rand"

	"github.com/asynkron/protoactor-go/actor"
)

// function to check if value exists in slice
func contains(slice []string, value string) bool {
	for _, v := range slice {
		if v == value {
			return true
		}
	}
	return false
}

// Message types
type RegisterUser struct {
	Username string
}

type CreateSubreddit struct {
	Name string
}

type JoinSubreddit struct {
	UserID       string
	SubredditName string
}

type LeaveSubreddit struct {
	UserID       string
	SubredditName string
}

// user actor
type UserActor struct {
	ID       string
	Username string
	Karma    int
	SubredditList []string
}

// behavior for user actor, which will act as listener
func (state *UserActor) Receive(ctx actor.Context) {
	switch msg := ctx.Message().(type) {
	case *RegisterUser:
		state.Username = msg.Username
		fmt.Printf("User %s registered.\n", state.Username)

	case *JoinSubreddit:
		if !contains(state.SubredditList, msg.SubredditName) {
			state.SubredditList = append(state.SubredditList, msg.SubredditName)
			fmt.Printf("User %s joined subreddit %s.\n", state.ID, msg.SubredditName)
			// fmt.Println(state.SubredditList)
		}
	
	case *LeaveSubreddit:
		currsubreddits := state.SubredditList
		// fmt.Println("Before") // DEBUG
		// fmt.Println(currsubreddits) // DEBUG
		for i, v := range currsubreddits {
			
			if v == msg.SubredditName {
				// Remove the element at index i
				currsubreddits = append(currsubreddits[:i], currsubreddits[i+1:]...)
			}
		}
		state.SubredditList = currsubreddits
		// fmt.Println("After") // DEBUG
		// fmt.Println(currsubreddits) // DEBUG
	}
}

// Subreddit Actor
type SubredditActor struct {
	Name  string
	Posts []*PostActor // List of posts in the subreddit.
	UserList []string
}

// behavior for sub reddit, to listen to incoming messages
func (state *SubredditActor) Receive(ctx actor.Context) {
	switch msg := ctx.Message().(type) {
	case *CreateSubreddit:
		state.Name = msg.Name
		fmt.Printf("Subreddit %s created.\n", state.Name)

	case *JoinSubreddit:
		if !contains(state.UserList, msg.UserID) {
			state.UserList = append(state.UserList, msg.UserID)
		}
	
	case *LeaveSubreddit:
		currusers := state.UserList
		// fmt.Println("Before") // DEBUG
		// fmt.Println(currusers) // DEBUG
		for i, v := range currusers {
			
			if v == msg.UserID {
				// Remove the element at index i
				currusers = append(currusers[:i], currusers[i+1:]...)
			}
		}
		state.UserList = currusers
		// fmt.Println("After")  // DEBUG
		// fmt.Println(currusers)  // DEBUG
	}

}

// Post Actor (for simplicity, not making it a full actor here)
type PostActor struct {
	UserID  string
	Content string
}

// Engine Actor (Orchestrator)
type EngineActor struct {
	users      map[string]*actor.PID
	subreddits map[string]*actor.PID
}

// function to return pointer to engine actor with empty map of users and subreddits
func NewEngineActor() *EngineActor {
	return &EngineActor{
		users:      make(map[string]*actor.PID),
		subreddits: make(map[string]*actor.PID),
	}
}

// behavior for engineActor, to listen for incoming messages
func (state *EngineActor) Receive(ctx actor.Context) {
	// checking msg type, based on msg struct
	switch msg := ctx.Message().(type) {

	case *RegisterUser:
		userProps := actor.PropsFromProducer(func() actor.Actor { return &UserActor{ID: msg.Username} })
		userPID := ctx.Spawn(userProps)
		state.users[msg.Username] = userPID
		// fmt.Printf("User %s registered.\n", msg.Username)
	
	case *CreateSubreddit:
		subredditProps := actor.PropsFromProducer(func() actor.Actor { return &SubredditActor{Name: msg.Name} })
		subredditPID := ctx.Spawn(subredditProps)
		state.subreddits[msg.Name] = subredditPID
		// fmt.Printf("Subreddit %s created.\n", msg.Name)
	
	case *JoinSubreddit:
		if subredditPID, ok := state.subreddits[msg.SubredditName]; ok {
			user := state.users[msg.UserID]
			ctx.Send(subredditPID, &JoinSubreddit{UserID: msg.UserID})
			ctx.Send(user, &JoinSubreddit{SubredditName: msg.SubredditName})
			// fmt.Printf("User %s joined subreddit %s.\n", msg.UserID, msg.SubredditName)
		} else {
			fmt.Printf("Subreddit %s not found.\n", msg.SubredditName)
		}
	
	case *LeaveSubreddit:
		if subredditPID, ok := state.subreddits[msg.SubredditName]; ok {
			user := state.users[msg.UserID]
			ctx.Send(subredditPID, &LeaveSubreddit{UserID: msg.UserID})
			ctx.Send(user, &LeaveSubreddit{SubredditName: msg.SubredditName})
		} else {
			fmt.Printf("Subreddit %s not found.\n", msg.SubredditName)
		}

	default:
		log.Println("Unknown message type received")
	}
}		

// function to simulate our reddit engine for multi-user scenario
func simulateUsers(rootContext *actor.RootContext, enginePID *actor.PID, numUsers int) {

	//Approach:
	// create 10 users (Done)
	// create 5 subreddits (Done)
	// for each user, use random function (5 times) and assign the user to random subreedits among available ones (Done)
	// run for loop for 20 times, make random posts by users in subreddits
	// run for loop for 20 times, make random comments (non-hierarchial0)
	// upvote 100 times, random posts
	// downvote 100 times random posts
	// make 2 users leave the subreddit
	// get feed for all 5 subreddits

	// creating 10 users
	for i := 0; i < numUsers; i++ {
        username := fmt.Sprintf("user%d", i+1)

        // Register the user.
        rootContext.Send(enginePID, &RegisterUser{Username: username})
	}

	// creating 5 subredits
	for i := 0; i < 5; i++ {
		subredditName := fmt.Sprintf("sub%d", i+1)
		rootContext.Send(enginePID, &CreateSubreddit{Name: subredditName})
	}

	// join subreddits
	for i := 0; i < 10; i++ {
		username := fmt.Sprintf("user%d", i+1)
		for j := 0; j < 5; j++ {
			subredditName := fmt.Sprintf("sub%d", rand.Intn(5)+1) // Randomly choose from 5 subreddits.

			rootContext.Send(enginePID, &JoinSubreddit{UserID: username, SubredditName: subredditName})
		}
	}

	// users leaves randomly
	for i:= 0; i< 5; i++ {
		username := fmt.Sprintf("user%d", rand.Intn(10)+1)
		subredditname:= fmt.Sprintf("sub%d", rand.Intn(5)+1)

		// time.Sleep(3 * time.Second)
		// fmt.Println(username)
		// fmt.Println(subredditname)

		rootContext.Send(enginePID, &LeaveSubreddit{UserID: username, SubredditName: subredditname})
	}

}

func main() {

	// a central point for our actors and managing their lifecycle
	system := actor.NewActorSystem() 
	rootContext := system.Root

	// defining the properties of actor anf using it to spawn an instance
	engineProps := actor.PropsFromProducer(func() actor.Actor { return NewEngineActor() })
	enginePID := rootContext.Spawn(engineProps)

    // initiate simulator
    simulateUsers(rootContext, enginePID, 10)

	// delay main thread for some time,
	// allow other processes to finish
	time.Sleep(8 * time.Second) 
}