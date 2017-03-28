/************************************************************************************************/
/* i-Code CNES is a static code analyzer.                                                       */
/* This software is a free software, under the terms of the Eclipse Public License version 1.0. */
/* http://www.eclipse.org/legal/epl-v10.html                                                    */
/************************************************************************************************/
package fr.cnes.analysis.tools.ui.handler;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.JobChangeAdapter;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;

import fr.cnes.analysis.tools.analyzer.AbstractAnalysisJob;
import fr.cnes.analysis.tools.analyzer.RuleAnalysisJob;
import fr.cnes.analysis.tools.analyzer.datas.Violation;
import fr.cnes.analysis.tools.ui.view.ViolationsView;

/**
 * This class is the Handler that linked together action button on the menu and
 * analyze function located
 * 
 */
public class RuleAnalysisHandler extends AbstractAnalysisHandler {
    /**
     * Logger
     */
    private static final Logger LOGGER = Logger.getLogger(RuleAnalysisHandler.class.getName());

    /**
     * List of all files that will be analyzed
     */
    private List<String> analyzedFiles = new ArrayList<String>();

    /**
     * Selected project for the analysis
     */
    private IProject selectedProject = getActiveProject();

    /**
     * Run the analysis on the retrieved files.
     * 
     * @param files
     *            the files to analyze
     * @param pAnalyzerID
     *            the id of analyzer on which the analysis is made
     */
    @Override
    public void runAnalysis(final List<IPath> files, final String pAnalyzerID) {

        LOGGER.finest("Begin runAnalysis method");

        // Clear the analyzedFiles list in order to have the new analyzed files
        analyzedFiles.clear();

        // Instantiate analyzer
        final AbstractAnalysisJob analysis = new RuleAnalysisJob(pAnalyzerID, files);

        // run analysis
        analysis.setUser(true);
        analysis.schedule();

        // add change listener to check when the job is done
        analysis.addJobChangeListener(new JobChangeAdapter() {

            @Override
            public void done(final IJobChangeEvent event) {
                Display.getDefault().asyncExec(new Runnable() {

                    @Override

                    public void run() {
                        if (analysis.getResult().isOK()) {
                            RuleAnalysisHandler.this
                                    .updateView(((RuleAnalysisJob) event.getJob()).getViolations());
                        }
                    }

                });
            }
        });

        LOGGER.finest("End runAnalysis method");
    }

    /**
     * Update the violation's view
     * 
     * @param violations
     *            .
     */
    protected void updateView(final List<Violation> violations) {
        LOGGER.finest("Begin updateView method");

        try {
            // get the page
            final IWorkbenchPage page = PlatformUI.getWorkbench().getActiveWorkbenchWindow()
                    .getActivePage();

            // open view
            page.showView(ViolationsView.VIEW_ID);

            // get view
            final ViolationsView view = (ViolationsView) page.findView(ViolationsView.VIEW_ID);

            // show rules analyze results
            if (view != null) {
                view.display(violations, this.getSelectedProject(), this.getAuthor(),
                        this.getDate());
            }

        } catch (final PartInitException exception) {
            LOGGER.log(Level.FINER, exception.getClass() + " : " + exception.getMessage(),
                    exception);
            MessageDialog.openError(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
                    "Internal Error", "Contact support service : \n" + exception.getMessage());
        }

        LOGGER.finest("End updateView method");
    }

    /**
     * @return Date of the analysis
     */
    public String getDate() {
        final String format = "YYYY-MM-dd";
        final SimpleDateFormat formater = new SimpleDateFormat(format);
        final Date date = new Date();
        return (formater.format(date));
    }

    /**
     * @return IProject Project selected in the active view
     */
    public IProject getActiveProject() {

        // Set the project null
        IProject project = null;

        // Get the selection
        final ISelection selection = PlatformUI.getWorkbench().getActiveWorkbenchWindow()
                .getActivePage().getActivePart().getSite().getSelectionProvider().getSelection();

        // Get the project of the element selected
        if (selection instanceof IStructuredSelection) {
            final Object element = ((IStructuredSelection) selection).getFirstElement();

            if (element instanceof IResource) {
                project = ((IResource) element).getProject();
            }
        }
        return project;
    }

    /**
     * @return selectedProject class attribute
     */
    public IProject getSelectedProject() {
        return selectedProject;
    }

    /**
     * @return The Eclipse user name that ran the analysis
     */
    private String getAuthor() {
        String author = System.getProperty("user.name");
        if (author.isEmpty()) {
            author = "Unknown";
        }
        return author;
    }

}
