# FreshBooks integration for Redmine

Plugin for Redmine. Adds the ability to associate Redmine projects with FreshBooks
Projects and push Redmine time entries to FreshBooks. This is exclusively for
the New FreshBooks as opposed to Classic FreshBooks.

If you are currently running Classic FreshBooks you will need to migrate to New
before using this plugin.

## Install

  1. download and install the plugin from the [releases page](https://github.com/dojo4/redmine_freshbooks_sync/releases).
      ```sh
      cd <REDMINE_ROOT>/plugins
      curl -L https://github.com/dojo4/redmine_freshbooks_sync/archive/v0.5.0.tar.gz -o redmine_freshbooks_sync-0.5.0.tgz
      tar zxf redmine_freshbooks_sync-0.5.0.tgz
      mv redmine_freshbooks_sync-0.5.0 redmine_freshbooks_sync
      rm redmine_freshbooks_sync-0.5.0.tgz
      ```
  2. In the redmine root folder:
     * `bundle install`
     * `bundle exec rake redmine:plugins:migrate RAILS_ENV=production NAME=redmine_freshbooks_sync`
  3. Restart your redmine instance

## Uninstall

  1. In the Redmine root folder:
     * `bundle exec rake redmine:plugins:migrate RAILS_ENV=production NAME=redmine_freshbooks_sync VERSION=0`
  2. from the Redmine root folder remove the `plugins/redmine_freshbooks_sync`
     directory
  3. Restart your redmine instance

## Configure

These instructions are also available on your redmine instance in the
configuration settings for this plugin.  Head over to `https://my-redmine-instance/settings/plugin/redmine_freshbooks_sync`

1. Go to the [FreshBooks Developer Portal](https://my.freshbooks.com/#/developer) and click the green **Create an App** button
2. Fill out the form with the following information
  * Application Name: `My company Redmine`
  * Description: `Synchronize Redmine projects and time entries with FreshBooks`
  * Website URL: `https://my-redmine-instance-hostname`
  * Application Settings URL: `https://my-redmine-instance-hostname/settings/plugin/redmine_freshbooks_sync`
  * Redirect URL: `https://my-redmine-instance-hostname/freshbooks/redirect`
3. Click **Save** to be directed back to your FreshBooks Developer Page
4. Twist open the newly created app entry.
5. Copy the **Client ID** into the Client ID field of the plugin settings.
6. Copy the **Client Secret** into the Client Secret field of the plugin settings.
7. Set the **Earliest Time Entry Date** to the earliest date to start pushing
   time entries to FreshBooks. It defaults to the first of the current month.
7. Save your settings
8. Click on **FreshBooks** in the **Administration** menu to go to the FreshBooks module.
9. Click on the blue **Authorize with FreshBooks** button to do the OAuth 2.0
   login. This will save a token and you generally shouldn't have to do this
   again. If the button shows up again, just press it.

## Setup Synchronization

In the FreshBooks module you will see 3 tabs **Identity**, **Projects**, and
**Time Entries**.

* You'll want to setup initial associations between Redmine projects and FreshBooks
  projects in the **Projects** tab.
* Then Check the **Time Entries** tab to do an initial push of existing time 
  entries to FreshBooks
* After than, the only maintenance that should be necessary is when new projects
  are created in Redmine and FreshBooks and the new associations need to be
  setup.

### Identity Tab

This page just shows your identity in FreshBooks. The left side should show your
account name in FreshBooks and your mailing address in FreshBooks.

The Right side are a few handy deep links into FreshBooks.

### Projects tab

The first thing you will want to do is push the **Sync Projects** button, this
will start pulling a list all the active projects from FreshBooks to your
redmine instance and setting up a table for you to associate Redmine Projects
with FreshBooks Projects.

Reload this page until **Last Synchronization** appears at the top of
the page.

Now you can start associating Redmine Projects with FreshBooks Projects.

The table columns are:

* **Name** - The Redmine project name - clicking on the name will take you to
    the Redmine project page.
* **Mapping State** - the state of the redmine project mapping. This can be
    **internal**, **unmapped**, **mapped**. Internal projects are those that are
    only in Redmine and not associate with FreshBooks projects.
* **FreshBooks Project** - this shows the currently mapped freshbooks project,
    or a dropdown list of freshbooks projects to potentially associate. Clicking
    on the linked name will take you to the FreshBooks project page.
* **Action** - these are the various actions that you can take for that row.
  * **Associate** - Select a FreshBooks Project from the dropdown and press this
      button to associate the Redmine project with the FreshBooks project from
      the dropdown.
  * **Mark Internal** - Mark this Redmine project as internal only and do not
      associate it with a FreshBooks project.
  * **Mark Associable** - this only shows up on projects marked internal.
      Pressing this button will remove the internal flag and allow the Redmine
      project to be associated with a FreshBooks project.

### Time Entries

This tab shows all the Time Entries that are pushed to FreshBooks and their
current state.

At the top is the last time time entries were synced.

The first time here - you'll want to review the initial time entries and make
sure that these are all the ones you want to sync. The **Settings** for this
plugin determine the earliest date of time entries to push. Please make sure that
that settings date is what you want.

##
