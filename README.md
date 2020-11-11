# Freshbooks integration for Redmine

Plugin for Redmine. Adds the ability to associate Redmine projects with Freshbooks
Projects and push Redmine time entries to Freshbooks. This is exlucsively for
the New Freshbooks as opposd to Classic Freshbooks.

If you are currently running Classic Freshbooks you will need to migrate to New
before using this plugin.

## Install

  1. download the plugin either from the releases page, or git checkout
  2. In the redmine root folder:
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

1. Go to the [Freshbooks Developer Portal](https://my.freshbooks.com/#/developer) and click the green **Create an App** button
2. Fill out the form with the following information
  * Application Name: `My company Redmine`
  * Description: `Synchronize Redmine projects and time entries with Freshbooks`
  * Website URL: `https://my-redmine-instance-hostname`
  * Application Settings URL: `https://my-redmine-instance-hostname/settings/plugin/redmine_freshbooks_sync`
  * Redirect URL: `https://my-redmine-instance-hostname/freshbooks/redirect`
3. Click **Save** to be directed back to your Freshbooks Developer Page
4. Twist open the newly created app entry.
5. Copy the **Client ID** into the Client ID field of the plugin settings.
6. Copy the **Client Secret** into the Client Secret field of the plugin settings.
7. Set the **Earliest Time Entry Date** to the earliest date to start pushing
   time entries to Freshbooks. It defaults to the first of the current month.
7. Save your settings
8. Click on **Freshbooks** in the **Administration** menu to go to the Freshbooks module.
9. Click on the blue **Authorize with Freshbooks** button to do the OAuth 2.0
   login. This will save a token and you generally shouldn't have to do this
   again. If the button shows up again, just press it.

## Setup Synchronization

In the Freshbooks module you will see 3 tabs **Identity**, **Projects**, and
**Time Entries**.

* You'll want to setup initial associations between Redmine projects and Freshbooks
  projects in the **Projects** tab.
* Then Check the **Time Entries** tab to do an initial push of existing time 
  entries to Freshbooks
* After than, the only maintenance that should be necessary is when new projects
  are created in Redmine and Freshbooks and the new associations need to be
  setup.

### Identity Tab

This page just shows your identity in Freshbooks. The left side should show your
account name in Freshbooks and your mailing address in Freshbooks.

The Right side are a few handy deep links into Freshbooks.

### Projects tab

The first thing you will want to do is push the **Sync Projects** button, this
will start pulling a list all the active projects from Freshbooks to your
redmine instance and setting up a table for you to associate Redmine Projects
with Freshbooks Projects.

Reload this page until **Last Synchronization** appears at the top of
the page.

Now you can start associating Redmine Projects with Freshbooks Projects.

The table columns are:

* **Name** - The Redmine project name - clicking on the name will take you to
    the Redmine project page.
* **Mapping State** - the state of the redmine project mapping. This can be
    **internal**, **unmapped**, **mapped**. Internal projects are those that are
    only in Redmine and not associate with Freshbooks projects.
* **Freshbooks Project** - this shows the currently mapped freshbooks project,
    or a dropdown list of freshbooks projects to potentially associate. Clicking
    on the linked name will take you to the Freshbooks project page.
* **Action** - these are the various actions that you can take for that row.
  * **Associate** - Select a Freshbooks Project from the dropdown and press this
      button to associate the Redmine project with the Freshbooks project from
      the dropdown.
  * **Mark Internal** - Mark this Redmine project as internal only and do not
      associate it with a Freshbooks project.
  * **Mark Associable** - this only shows up on projects marked internal.
      Pressing this button will remove the internal flag and allow the Redmine
      project to be associated with a Freshbooks project.

### Time Entries

This tab shows all the Time Entries that are pushed to Freshbooks and their
current state.

At the top is the last time time entries were synced.

The first time here - you'll want to review the initial time entries nad make
sure that these are all the ones you want to sync. The **Settings** for this
plugin determine the earliest date of time entries to push. Pleas make sure that
that settings date is what you want.

##
