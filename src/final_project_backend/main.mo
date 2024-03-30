
import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

actor EventManager {

    type Event = {
        title: Text;
        description: Text;
        completed: Bool;
        attendees: Nat;
    };

    type Account = {
        username: Text;
        password: Text;
        isAdmin: Bool;
    };

    func natHash(n: Nat): Hash.Hash {
        Text.hash(Nat.toText(n))
    };

    func textHash(t: Text): Hash.Hash {
        Text.hash(t)
    };

    var events = Map.HashMap<Nat, Event>(0, Nat.equal, natHash);
    var accounts = Map.HashMap<Text, Account>(0, Text.equal, textHash);
    var nextId: Nat = 0;

    
    let _ = 
        accounts.put("admin", { username = "admin"; password = "admin"; isAdmin = true });// Create the admin account

    public func register(username: Text, password: Text): async Bool {
        if (accounts.get(username) != null) {
            false // Username already exists
        } else {
            accounts.put(username, { username; password; isAdmin = false });
            true // Registration successful
        }
    };



    // Login function
    public func login(username: Text, password: Text): async Bool {
      let ?account = accounts.get(username);
      if (account.password == password) { // Check if account exists AND password matches
          true
      } else {
          false
      }
    };

    // Get all events
    public query func getEvents(): async [Event] {
        Iter.toArray(events.vals())
    };

    // Creating an event (only accessible to admin)
    public func createEvent(title: Text, description: Text,username: Text, password: Text): async Nat {
        let ?account = accounts.get(username);
        if (account.password == password and account.isAdmin) {
          let id = nextId;
          events.put(id, { title; description; completed = false; attendees = 0 });
          nextId += 1;
          id
        } else {
          0
        };
    };

    // Registering members (increasing attendees)
    public func registerMember(id: Nat, username: Text, password: Text): async Bool {
        let ?account = accounts.get(username);
        if (account.password == password) {
          ignore do ? {
              let event = events.get(id)!;
              events.put(id, { title=event.title; description=event.description; completed=event.completed; attendees = event.attendees + 1 });
          }
        };
        true
    };


    // Marking an event as completed (only accessible to admin)
    public func completeEvent(id: Nat, username: Text, password: Text): async Bool {
        let ?account = accounts.get(username);
        if (account.password == password) {
          ignore do ? {
              let event = events.get(id)!;
              events.put(id, {title=event.title; description=event.description; completed=true; attendees = event.attendees});
          };
        };
        true
    };

    public query func showEvents() : async Text { // Show all events with infos clear
        var output: Text = "\n_____EVENTS_____";
        for (event: Event in events.vals()) {
            output #= "\nEvent Name: " # event.title;
            output #= " Description: " # event.description;
            output #= " Attandees: " # Nat.toText(event.attendees);
            if (event.completed) {output #= " ✔"; };
        };
        output # "\n"
    };

}
