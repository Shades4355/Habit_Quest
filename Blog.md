# COMP 4631 – Mobile App II
## Blog
### Feb 5th, 2026
The team met twice this week, on Tuesday and Wednesday, to practice our presentation. Subsequently, we presented our project for the class.

Finally, we met with the professor to talk about the details of our project, and got approval to move forward with it.

Shades started a System Architecture & Design Document (SADD) that will guide development of the app and will guide the development of the testing documents.


### 08-Feb-2026
Shades accepted the assignment, creating an appropriately named repository. A blank app was created, to be the bones of Habit Quest. The team was subsequently notified.


### 10-Feb-2026
Team meeting #3 was delayed until 11-Feb-2026 due to a last minute conflict.

Since the last post, Shades finished the SADD, and has fleshed out the Trello with assignments and time tables.


### 11-Feb-2026
Team meeting #3:

Team members in attendance: all present

Since last week the team has started looking at Flutter and getting used to it.

The team went over the System Architecture & Design Document. Most items were accepted, or changed and then accepted. A few items have been left as “pending”, to be reviewed again at a later date.


### 17-Feb-2026
Team meeting #4

In attendance: Shades, Luca, Miguel

Since last week, Shades has started writing the Master Test Document, which will be used to spin off smaller test documents for the team to use during internal testing.

Luca looked into Dart syntax.

Miguel has been practicing Dart by re-making a past project. He has also been looking into database options that are compatible with Dart. Additionally, Miguel has also been looking into how to `build` our eventual app for IOS and Android devices.

This week the Luca is going to start the mock-up for the demo.

Miguel will start looking into more of the back-end side of Dart's logic.

We talked about the demo, and settled on demoing the 5th (if we can).

Per Miguel’s suggestion, we now have a Discord server for better organizing our communications. Up until now we were using a group chat only.


### 24-Feb-2026
Team meeting #5

In attendance: Shades and Luca

Absent without prior messaging: Marvens

Late because of a Valorant match: Miguel

Since last week, Luca worked on the UI for the Demo. He also implemented the UI’s orientation locks.

Shades has made slow progress on the master testing document, due to a 3 day long headache.

On 23-Feb., Luca requested Marvens assist by moving several functions into separate files in new folders (ex: a “screens” folder for all the screen files) to make the code easier to maintain and improve. Marvens has not yet responded.

Miguel has started working with the database on his learning side project. He has also been researching how to implement our stretch goal, should we have time. Miguel has also started looking at “fluttertoast” as a replacement for Flutter’s “snackbar” notifications.

This week, Luca needs to wait for more back-end work to be done before continuing with front-end polish.

Shades plans to continue writing the master testing document, as well as review and hopefully merge Luca’s demo UI branch by Friday EoD.

Miguel plans to switch from the side project to working on Habit Quest once the file structure is sorted.

Current blockers: at least 3/4th of the team is needed to finalize the remaining pending items in the SADD. And Miguel needs Marvens to finish modifying the file structure before Miguel can meaningfully start on the back-end.

Current state: we have a front-end; we need the back-end; and our file structure needs to be adjusted.


### 03-March-2026
Team meeting #6:

In attendance: Shades, Luca, Marvens, Miguel

Since last week, Shades has written more manual tests, and has started reading up on how to write widget tests.

Marvens has started and finished working on the 7-day and 30-day graphs.

And Miguel has been working on the database.

Today, we went over the SADD. We talked about the remaining pending items, as well as some UI changes. We additionally worked together to troubleshoot some technical difficulties.

Miguel is planning to finish up with the database this week.

Marvens is planning to get our calendar and clock UI libraries integrated this week.

Luca will start working on Dark Mode and add a toggle for “Show Deadlines” in the settings.


### 10-March-2026
Team meeting #7:

In attendance: Shades, Miguel, Marvens

Not in attendance, but responsive on Discord: Luca

Since last week, Miguel and Marvens worked on implementing the Database, the Notification settings, and the graphs. Shades worked on writing tests - manual test instructions and widget tests.

This week, Miguel will try to refactor the code to remove the `habitRepo` requirement from several classes. Marvens will work on adding functionality to the Show Deadlines toggle and fix the order of the displayed Date. Shades will try to finish writing the instructions for the manual tests, and, if Miguel’s refactoring completes before next week, Shades will also start refactoring the widget tests. And Luca will refactor the files and class names to be snake case instead of Pascal case, per Flutter's conventions.


### 18-March-2026
Team meeting #8:

In attendance: everyone

By majority consent, we moved this meeting from the 17th to the 18th.

Since the last meeting, Luca attempted to refactor the file names, but encountered an unusually high number of errors. Shades picked up the task and finished the refactoring. Miguel worked on refactoring the code to make it possible to run widget tests; he has mostly finished. Shades attempted to run widget tests with the new refactoring, but is stuck on how to mock up a database for the testing environment. Marvens started working on the toggle feature for the deadlines display.

For this week, Luca will work on refactoring the interface windows to be dynamically sized instead of statically sized. Marvens will continue work on the toggle feature for the deadlines. Miguel will work on connecting the Habits History page to the database. Shades will continue working on the Master Testing Document and widget testing.

Luca was having some difficulties with his emulators; we troubleshooted as a group.


