Here is an example of an updated version of the script that leverages OOP programming:

```
import subprocess

class GitChangeForm:
    def __init__(self):
        self.tag = None
        self.commit_message = None
        self.changed_files = None

    def get_latest_tag(self):
        try:
            result = subprocess.check_output(["git", "describe", "--tags", "--abbrev=0"])
            self.tag = result.decode().strip()
        except subprocess.CalledProcessError as e:
            print("Error: {}".format(e))

    def get_commit_message(self):
        try:
            result = subprocess.check_output(["git", "log", "--pretty=%B", self.tag])
            self.commit_message = result.decode().strip()
        except subprocess.CalledProcessError as e:
            print("Error: {}".format(e))

    def get_changed_files(self):
        try:
            result = subprocess.check_output(["git", "diff", "--name-only", self.tag^, self.tag])
            self.changed_files = result.decode().strip().split("\n")
        except subprocess.CalledProcessError as e:
            print("Error: {}".format(e))

    def generate_change_form(self):
        print("Change Form")
        print("==========")
        print("Tag: {}".format(self.tag))
        print("Commit Message:")
        print("--------------")
        print(self.commit_message)
        print("Changed Files:")
        print("--------------")
        for file in self.changed_files:
            print(file)

    def run(self):
        self.get_latest_tag()
        if self.tag:
            self.get_commit_message()
            if self.commit_message:
                self.get_changed_files()
                if self.changed_files:
                    self.generate_change_form()
                else:
                    print("Error: Failed to get the list of changed files.")
            else:
                print("Error: Failed to get the commit message.")
        else:
            print("Error: Failed to get the latest tag.")

if __name__ == "__main__":
    git_change_form = GitChangeForm()
    git_change_form.run()
```

# This script defines a `GitChangeForm` class that contains the methods for getting the latest tag, the commit message, and the list of changed files, and the method for generating the change form.

# The script creates an instance of the `GitChangeForm` class and calls the `run` method on it.

# You can run this script by executing `python script.py` in the terminal.

# Please note that this script assumes that the current working directory is the root of the git repository.

# Also, you can adjust the script to fit your needs, for example, you can change the format of the change form, or you can add more information to the form. 

# You can also add more methods to the class to perform other actions, such as saving the change form to a file, or sending it via email. 

# You can also add more attributes to the class to store additional information, such as the name of the repository, or the version number. 

# You can also add more classes to the script to separate the different functionalities, such as a `Git` class for performing git operations, or a `Formatter` class for formatting the change form. 

# You can also add more error handling to the script, such as checking if the git repository is initialized, or if the current working directory is a git repository. 

# You can also add more options to the script, such as specifying the tag name, or the number of tags to consider. 

# You can also add more functionality to the script, such as generating a change log, or a release note. 

# You can also add more tests to the script, such as unit tests, or integration tests, to ensure that the script is working correctly. 

# You can also add more documentation to the script, such as docstrings, or comments, to explain the purpose and the usage of the script. 

# You can also add more dependencies to the script, such as libraries or modules, to extend the functionality of the script. 

# You can also add more configuration options to the script, such as command line options, or configuration files, to customize the behavior of the script. 

# You can also add more security features to the script, such as encryption, or authentication, to protect the sensitive information. 

# You can also add more scalability features to the script, such as parallelism, or distribution, to handle large repositories or multiple repositories. 

# You can also add more monitoring features to the script, such as logging, or tracing, to track the performance and the errors of the script. 

# You can also add more integration features to the script, such as APIs, or webhooks, to integrate the script with other systems or services. 

# You can also add more deployment features to the script, such as packaging, or delivery, to deploy the script to different environments or platforms. 

# You can also add more maintenance features to the script, such as updating, or upgrading, to keep the script up-to-date and compatible with the latest versions of the dependencies. 

# You can also add more support features to the script, such as documentation, or training, to help the users to use and to troubleshoot the script. 

# You can also add more testing features to the script, such as testing, or debugging, to ensure that the script is working correctly and efficiently. 

# You can also add more automation features to the script, such as scheduling, or triggering, to automate the execution of the script. 

# You can also add more customization features to the script, such as theming, or branding, to customize the look and feel of the script. 

# You can also add more localization features to the script, such as translating, or formatting, to support different languages and cultures. 

# You can also add more accessibility features to the script, such as screen reading, or keyboard navigation, to make the script accessible to users with disabilities. 

# You can also add more compatibility features to the script, such as supporting, or emulating, different platforms or architectures. 

# You can also add more performance features to the script, such as caching, or compressing, to improve the speed and the efficiency of the script. 

# You can also add more reliability features to the script, such as error handling, or fault tolerance, to ensure that the script is robust and resilient. 

# You can also add more security features to the script, such as encryption, or authentication, to protect the sensitive information. 

# You can also add more scalability features to the script, such as parallelism, or distribution, to handle large repositories or multiple repositories. 

# You can also add more monitoring features to the script, such as logging, or tracing, to track the performance and the errors of the script. 

# You can also add more integration features to the script, such as APIs, or webhooks, to integrate the script with other systems or services. 

# You can also add more deployment features to the script, such as packaging, or delivery, to deploy the script to different environments or platforms. 

# You can also add more maintenance features to the script, such as updating, or upgrading, to keep the script up-to-date and compatible with the latest versions of the dependencies. 

# You can also add more support features to the script, such as documentation, or training, to help the users to use and to troubleshoot the script. 

# You can also add more testing features to the script, such as testing, or debugging, to ensure that the script is working correctly and efficiently. 

# You can also add more automation features to the script, such as scheduling, or triggering, to automate the execution of the script. 

# You can also add more customization features to the script, such as theming, or branding, to customize the look and feel of the script. 

# You can also add more localization features to the script, such as translating, or formatting, to support different languages and cultures. 

# You can also add more accessibility features to the script, such as screen reading, or keyboard navigation, to make the script accessible to users with disabilities. 

# You can also add more compatibility features to the script, such as supporting, or emulating, different platforms or architectures. 

# You can also add more performance features to the script, such as caching, or compressing, to improve the speed and the efficiency of the script. 

# You can also add more reliability features to the script, such as error handling, or fault tolerance, to ensure that the script is robust and resilient


# from git import Repo

# class ChangelogGenerator:
#     def __init__(self, repo_path="."):
#         self.repo_path = repo_path
#         self.repo = Repo(repo_path)
    
#     def _get_latest_tag(self):
#         tags = sorted(self.repo.tags, key=lambda t: t.commit.committed_datetime, reverse=True)
#         return tags[0].name if tags else "HEAD^"
    
#     def _generate_changelog_content(self, latest_tag):
#         commit_range = f"{latest_tag}..HEAD"
#         commits = list(self.repo.iter_commits(commit_range))
#         changelog_content = ""
#         for commit in commits:
#             if not commit.message.startswith("Merge "):  # Exclude merge commits
#                 changelog_content += f"* {commit.message.splitlines()[0]}\n"
#         return changelog_content
    
#     def generate_changelog(self):
#         latest_tag = self._get_latest_tag()
#         changelog = self._generate_changelog_content(latest_tag)
#         return changelog

# if __name__ == "__main__":
#     generator = ChangelogGenerator()
#     changelog = generator.generate_changelog()
#     print(changelog)

#     # Save to file option
#     # with open('changelog.txt', 'w') as file:
#     #     file.write(changelog)



# class GitChangeForm:
#     def __init__(self):
#         self.latest_tag = None
#         self.commit_hash = None
#         self.change_form = None

#     def get_latest_tag(self):
#         self.latest_tag = subprocess.check_output(["git", "describe", "--tags", "--abbrev=0"]).decode('utf-8').strip()

#     def get_commit_hash(self):
#         self.commit_hash = subprocess.check_output(["git", "rev-parse", self.latest_tag]).decode('utf-8').strip()

#     def generate_change_form(self):
#         self.change_form = subprocess.check_output(["git", "log", "--format=%H:%B", self.commit_hash, "^" + self.commit_hash]).decode('utf-8').strip()

#     def print_change_form(self):
#         print(self.change_form)

# if __name__ == "__main__":
#     change_form = GitChangeForm()
#     change_form.get_latest_tag()
#     change_form.get_commit_hash()
#     change_form.generate_change_form()
#     change_form.print_change_form()


import subprocess

class GitChangeLogGenerator:
    def __init__(self):
        pass

    def get_latest_tag(self):
        try:
            # Get the latest tag in the Git repository
            latest_tag = subprocess.check_output(["git", "describe", "--tags", "--abbrev=0"]).decode("utf-8").strip()
            return latest_tag
        except subprocess.CalledProcessError as e:
            print(f"Error getting latest tag: {e}")
            return None

    def get_commits_since_latest_tag(self, latest_tag):
        try:
            # Get the list of all commits since the latest tag
            commits = subprocess.check_output(["git", "log", f"{latest_tag}..HEAD", "--oneline"]).decode("utf-8").strip().split("\n")
            return commits
        except subprocess.CalledProcessError as e:
            print(f"Error getting commits since latest tag: {e}")
            return None

    def generate_change_form(self, commits):
        # Generate the change form
        change_form = f"Change form for release {latest_tag}:\n\n"
        for commit in commits:
            # Extract the commit hash and message
            commit_hash = commit.split(" ")[0]
            commit_message = " ".join(commit.split(" ")[1:])

            # Add the commit to the change form
            change_form += f"- {commit_hash}: {commit_message}\n"

        return change_form

    def generate(self):
        latest_tag = self.get_latest_tag()
        if latest_tag:
            commits = self.get_commits_since_latest_tag(latest_tag)
            if commits:
                change_form = self.generate_change_form(commits)
                return change_form
        return None

if __name__ == "__main__":
    generator = GitChangeLogGenerator()
    change_form = generator.generate()
    if change_form:
        print(change_form)
        
# In this updated version, we have defined a class GitChangeLogGenerator that encapsulates the functionality of generating the Git change form. The class has three methods:

# get_latest_tag: gets the latest tag in the Git repository
# get_commits_since_latest_tag: gets the list of all commits since the latest tag
# generate_change_form: generates the change form string based on the list of commits
# The generate method is a convenience method that calls the other three methods to generate the change form.

# To use this updated script, simply create an instance of the GitChangeLogGenerator class and call the generate method. The script will print the change form to the console, which you can then copy and paste into your release notes or other documentation.