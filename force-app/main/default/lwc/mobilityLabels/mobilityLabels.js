/** GUIDA INSERIMENTO CUSTOM LABELS
 * 
 * 1 - Accedere alla Org Salesforce e andare in SETUP --> CUSTOM LABELS
 * 2 - Cliccare su NEW CUSTOM LABEL
 * 3 - Compilare il form come segue:
 *              Short Description: Nome della Label in Inglese
 *              Name: dominio_posizione_nomeLabel (es. contactHistory_heading_date)
 *              Value: come Short Description
 * 4 - Cliccare su Save
 * 5 - Entrare nel Label appena creato e cliccare su New sotto Translate
 * 6 - Selezionare la lingua Italiana e aggiungere la traduzione della Label
 * 
 * 
 * 7 - Importare la Custom Label da Salesforce con:
 *              import nomeLabel from '@salesforce/label/c.nomeLabel';
 * 8 - Inserire nell'array Label il Name del nuovo custom label
 * 
 * 
 * 9 - Nel proprio componente richiamare il label dove serve: 
 *              HTML --> {_label.nomeLabel}
 * 
 */

import Active_Contracts from "@salesforce/label/c.Active_Contracts";
import Agency from "@salesforce/label/c.Agency";
import AgencyONE from "@salesforce/label/c.AgencyONE";
import Agent_View from "@salesforce/label/c.Agent_View";
import AgentNameAutoFilled from "@salesforce/label/c.AgentNameAutoFilled";
import Attachment_loading_block from "@salesforce/label/c.Attachment_loading_block";
import B2B_Insurance_Line_Page_Activity from "@salesforce/label/c.B2B_Insurance_Line_Page_Activity";
import B2B_Insurance_Line_Page_Car from "@salesforce/label/c.B2B_Insurance_Line_Page_Car";
import B2B_Insurance_Line_Page_HealthCare from "@salesforce/label/c.B2B_Insurance_Line_Page_HealthCare";
import B2B_Insurance_Line_Page_Other from "@salesforce/label/c.B2B_Insurance_Line_Page_Other";
import B2B_Insurance_Line_Page_Other_Businesses from "@salesforce/label/c.B2B_Insurance_Line_Page_Other_Businesses";
import blacklist_accidents from "@salesforce/label/c.blacklist_accidents";
import blacklist_broker from "@salesforce/label/c.blacklist_broker";
import blacklist_car from "@salesforce/label/c.blacklist_car";
import blacklist_commercial from "@salesforce/label/c.blacklist_commercial";
import blacklist_companies from "@salesforce/label/c.blacklist_companies";
import blacklist_disease from "@salesforce/label/c.blacklist_disease";
import blacklist_dwelling from "@salesforce/label/c.blacklist_dwelling";
import blacklist_include_all_campaigns from "@salesforce/label/c.blacklist_include_all_campaigns";
import blacklist_last_edit from "@salesforce/label/c.blacklist_last_edit";
import blacklist_protection from "@salesforce/label/c.blacklist_protection";
import blacklist_renewal from "@salesforce/label/c.blacklist_renewal";
import blacklist_save from "@salesforce/label/c.blacklist_save";
import blacklist_save_failed from "@salesforce/label/c.blacklist_save_failed";
import blacklist_save_success from "@salesforce/label/c.blacklist_save_success";
import blacklist_saving from "@salesforce/label/c.blacklist_saving";
import blacklist_service from "@salesforce/label/c.blacklist_service";
import campaign_aborted from "@salesforce/label/c.campaign_aborted";
import campaign_colNumber_customer from "@salesforce/label/c.campaign_colNumber_customer";
import campaign_colNumber_customers from "@salesforce/label/c.campaign_colNumber_customers";
import campaign_colNumber_noCustomer from "@salesforce/label/c.campaign_colNumber_noCustomer";
import campaign_completed from "@salesforce/label/c.campaign_completed";
import campaign_legend_agency from "@salesforce/label/c.campaign_legend_agency";
import campaign_legend_managementAXA from "@salesforce/label/c.campaign_legend_managementAXA";
import campaign_onGoing from "@salesforce/label/c.campaign_onGoing";
import campaign_planned from "@salesforce/label/c.campaign_planned";
import campaign_priority_prior from "@salesforce/label/c.campaign_priority_prior";
import campaign_priority_prioritary from "@salesforce/label/c.campaign_priority_prioritary";
import campaignCounters_activities from "@salesforce/label/c.campaignCounters_activities";
import campaignCounters_activityHistory from "@salesforce/label/c.campaignCounters_activityHistory";
import campaignCounters_history from "@salesforce/label/c.campaignCounters_history";
import campaignCounters_negotiations from "@salesforce/label/c.campaignCounters_negotiations";
import campaignCounters_onGoingNegotiations from "@salesforce/label/c.campaignCounters_onGoingNegotiations";
import campaignCounters_openActivities from "@salesforce/label/c.campaignCounters_openActivities";
import campaignCounters_opportunity from "@salesforce/label/c.campaignCounters_opportunity";
import campaignDetail_agency from "@salesforce/label/c.campaignDetail_agency";
import campaignDetail_alert from "@salesforce/label/c.campaignDetail_alert";
import campaignDetail_attached from "@salesforce/label/c.campaignDetail_attached";
import campaignDetail_attachedName from "@salesforce/label/c.campaignDetail_attachedName";
import campaignDetail_collaborator from "@salesforce/label/c.campaignDetail_collaborator";
import campaignDetail_customerTitle from "@salesforce/label/c.campaignDetail_customerTitle";
import campaignDetail_edit from "@salesforce/label/c.campaignDetail_edit";
import campaignDetail_moreInfo from "@salesforce/label/c.campaignDetail_moreInfo";
import campaignDetail_negotiationsCreatedPercentage from "@salesforce/label/c.campaignDetail_negotiationsCreatedPercentage";
import campaignDetail_negotiationsWon from "@salesforce/label/c.campaignDetail_negotiationsWon";
import campaignDetail_negotiationsWonEuro from "@salesforce/label/c.campaignDetail_negotiationsWonEuro";
import campaignDetail_negotiationsWonPercentage from "@salesforce/label/c.campaignDetail_negotiationsWonPercentage";
import campaignDetail_priority_prior from "@salesforce/label/c.campaignDetail_priority_prior";
import campaignDetail_priority_prioritary from "@salesforce/label/c.campaignDetail_priority_prioritary";
import campaignDetail_processing from "@salesforce/label/c.campaignDetail_processing";
import campaignDetail_targetCustomer from "@salesforce/label/c.campaignDetail_targetCustomer";
import campaignDetail_targetCustomers from "@salesforce/label/c.campaignDetail_targetCustomers";
import campaignDetail_title from "@salesforce/label/c.campaignDetail_title";
import campaignDetail_up from "@salesforce/label/c.campaignDetail_up";
import campaignDetail_upload from "@salesforce/label/c.campaignDetail_upload";
import campaignDetail_worked from "@salesforce/label/c.campaignDetail_worked";
import campaignDetail_workedCustomer from "@salesforce/label/c.campaignDetail_workedCustomer";
import campaignDetail_workedCustomerPercentage from "@salesforce/label/c.campaignDetail_workedCustomerPercentage";
import campaignDetail_workedPlur from "@salesforce/label/c.campaignDetail_workedPlur";
import campaignEdit_cancel from "@salesforce/label/c.campaignEdit_cancel";
import campaignEdit_save from "@salesforce/label/c.campaignEdit_save";
import CampaignLayout_CreatedByName from "@salesforce/label/c.campaignlayout_createdbyname";
import CampaignLayout_LastModifiedByName from "@salesforce/label/c.campaignlayout_lastmodifiedbyname";
import CampaignLayout_OwnerName from "@salesforce/label/c.campaignlayout_ownername";
import CampaignLayout_ParentName from "@salesforce/label/c.campaignlayout_parentname";
import CampaignLayout_RecordTypeName from "@salesforce/label/c.campaignlayout_recordtypename";
import campaignListPage_campaignList from "@salesforce/label/c.campaignListPage_campaignList";
import campaignListPage_endDate from "@salesforce/label/c.campaignListPage_endDate";
import campaignListPage_name from "@salesforce/label/c.campaignListPage_name";
import campaignListPage_new from "@salesforce/label/c.campaignListPage_new";
import campaignListPage_refresh from "@salesforce/label/c.campaignListPage_refresh";
import campaignListPage_startDate from "@salesforce/label/c.campaignListPage_startDate";
import campaignListPage_status from "@salesforce/label/c.campaignListPage_status";
import campaignListPage_statusCampaign from "@salesforce/label/c.campaignListPage_statusCampaign";
import campaignListPage_type from "@salesforce/label/c.campaignListPage_type";
import campaignNew_cancel from "@salesforce/label/c.campaignNew_cancel";
import campaignNew_create from "@salesforce/label/c.campaignNew_create";
import campaignProcessing_allFilters_ownerTwo from "@salesforce/label/c.campaignProcessing_allFilters_ownerTwo";
import campaignProcessing_allFilters from "@salesforce/label/c.campaignProcessing_allFilters";
import campaignProcessing_apply from "@salesforce/label/c.campaignProcessing_apply";
import campaignProcessing_assigns from "@salesforce/label/c.campaignProcessing_assigns";
import campaignProcessing_back from "@salesforce/label/c.campaignProcessing_back";
import campaignProcessing_campaignProcessing from "@salesforce/label/c.campaignProcessing_campaignProcessing";
import campaignProcessing_exclude from "@salesforce/label/c.campaignProcessing_exclude";
import campaignProcessing_resetFilters from "@salesforce/label/c.campaignProcessing_resetFilters";
import campaignProcessing_update from "@salesforce/label/c.campaignProcessing_update";
import campaignSmsEmailDeliveredEmail from "@salesforce/label/c.campaignSmsEmailDeliveredEmail";
import campaignSmsEmailDeliveredSms from "@salesforce/label/c.campaignSmsEmailDeliveredSms";
import campaignSmsEmailLabel from "@salesforce/label/c.campaignSmsEmailLabel";
import campaignSmsEmailNotDeliveredPercentage from "@salesforce/label/c.campaignSmsEmailNotDeliveredPercentage";
import campaignSmsEmailOpeningPercentage from "@salesforce/label/c.campaignSmsEmailOpeningPercentage";
import campaignSmsEmailPriorityCustomersPercentage from "@salesforce/label/c.campaignSmsEmailPriorityCustomersPercentage";
import campaignSmsEmailSent from "@salesforce/label/c.campaignSmsEmailSent";
import campaignStatus_Aborted from "@salesforce/label/c.campaignStatus_Aborted";
import campaignStatus_Completed from "@salesforce/label/c.campaignStatus_Completed";
import campaignStatus_Ongoing from "@salesforce/label/c.campaignStatus_Ongoing";
import campaignStatus_Planned from "@salesforce/label/c.campaignStatus_Planned";
import Cancel from "@salesforce/label/c.Cancel";
import case_header_category from "@salesforce/label/c.case_header_category";
import case_header_date from "@salesforce/label/c.case_header_date";
import case_header_description from "@salesforce/label/c.case_header_description";
import case_header_status from "@salesforce/label/c.case_header_status";
import case_header_subcategory from "@salesforce/label/c.case_header_subcategory";
import case_status_agentInfoReceived from "@salesforce/label/c.case_status_agentInfoReceived";
import case_status_forwardingToBusinessLine from "@salesforce/label/c.case_status_forwardingToBusinessLine";
import case_status_forwardingToIT from "@salesforce/label/c.case_status_forwardingToIT";
import case_status_inManagementAtHD3 from "@salesforce/label/c.case_status_inManagementAtHD3";
import case_status_inSpecialistManagement from "@salesforce/label/c.case_status_inSpecialistManagement";
import case_status_open from "@salesforce/label/c.case_status_open";
import case_status_solutionOffer from "@salesforce/label/c.case_status_solutionOffer";
import case_status_solutionRejected from "@salesforce/label/c.case_status_solutionRejected";
import case_status_specialistResponse from "@salesforce/label/c.case_status_specialistResponse";
import case_status_takenOver from "@salesforce/label/c.case_status_takenOver";
import case_status_waitingAgentInfo from "@salesforce/label/c.case_status_waitingAgentInfo";
import Categoria_ID from "@salesforce/label/c.Categoria_ID";
import ChangeOwnerValidationMessageNMA from "@salesforce/label/c.ChangeOwnerValidationMessageNMA";
import ChngOwnValidMsgNMAContabilita from "@salesforce/label/c.ChngOwnValidMsgNMAContabilita";
import ChooseACase from "@salesforce/label/c.ChooseACase";
import ChooseAClient from "@salesforce/label/c.ChooseAClient";
import Client from "@salesforce/label/c.Client";
import ClientONE from "@salesforce/label/c.ClientONE";
import ClosedCaseTaskNoneClosedError from "@salesforce/label/c.ClosedCaseTaskNoneClosedError";
import closeTheLoop_feedback from "@salesforce/label/c.closeTheLoop_feedback";
import contactHistory_flag_flagMouseoverBounce from "@salesforce/label/c.contactHistory_flag_flagMouseoverBounce";
import contactHistory_flag_flagMouseoverClick from "@salesforce/label/c.contactHistory_flag_flagMouseoverClick";
import contactHistory_flag_flagMouseoverOpen from "@salesforce/label/c.contactHistory_flag_flagMouseoverOpen";
import contactHistory_flag_flagMouseoverSent from "@salesforce/label/c.contactHistory_flag_flagMouseoverSent";
import contactHistory_heading_date from "@salesforce/label/c.contactHistory_heading_date";
import contactHistory_heading_typeOfInteraction from "@salesforce/label/c.contactHistory_heading_typeOfInteraction";
import contactHistory_status_bounce from "@salesforce/label/c.contactHistory_status_bounce";
import contactHistory_status_click from "@salesforce/label/c.contactHistory_status_click";
import contactHistory_status_open from "@salesforce/label/c.contactHistory_status_open";
import contactHistory_status_sent from "@salesforce/label/c.contactHistory_status_sent";
import Create from "@salesforce/label/c.Create";
import create_new_case from "@salesforce/label/c.create_new_case";
import CreateNewCase from "@salesforce/label/c.CreateNewCase";
import CreateRule from "@salesforce/label/c.CreateRule";
import customerCampaign_endDate_expires from "@salesforce/label/c.customerCampaign_endDate_expires";
import customerCampaign_status_excluding from "@salesforce/label/c.customerCampaign_status_excluding";
import customerCampaign_status_inCampaign from "@salesforce/label/c.customerCampaign_status_inCampaign";
import customerCampaign_status_infoRequest from "@salesforce/label/c.customerCampaign_status_infoRequest";
import customerCampaign_status_inPreparation from "@salesforce/label/c.customerCampaign_status_inPreparation";
import customerCampaign_status_interested from "@salesforce/label/c.customerCampaign_status_interested";
import customerCampaign_status_noAnswer from "@salesforce/label/c.customerCampaign_status_noAnswer";
import customerCampaign_status_noInterested from "@salesforce/label/c.customerCampaign_status_noInterested";
import customerCampaign_status_toAssign from "@salesforce/label/c.customerCampaign_status_toAssign";
import customerCampaign_status_toContact from "@salesforce/label/c.customerCampaign_status_toContact";
import customerCampaign_status_toRecontact from "@salesforce/label/c.customerCampaign_status_toRecontact";
import customerCampaign_status_toWork from "@salesforce/label/c.customerCampaign_status_toWork";
import customerCampaign_status_worked from "@salesforce/label/c.customerCampaign_status_worked";
import customerCampaign_status_wrongContact from "@salesforce/label/c.customerCampaign_status_wrongContact";
import customerCampaign_type_agency from "@salesforce/label/c.customerCampaign_type_agency";
import customerCampaign_type_campaignManagement from "@salesforce/label/c.customerCampaign_type_campaignManagement";
import CustomerView from "@salesforce/label/c.CustomerView";
import dataGrid_of from "@salesforce/label/c.dataGrid_of";
import dataGrid_results from "@salesforce/label/c.dataGrid_results";
import dataGrid_selected from "@salesforce/label/c.dataGrid_selected";
import dataGrid_update from "@salesforce/label/c.dataGrid_update";
import datapicker_April from "@salesforce/label/c.datapicker_April";
import datapicker_August from "@salesforce/label/c.datapicker_August";
import datapicker_December from "@salesforce/label/c.datapicker_December";
import datapicker_February from "@salesforce/label/c.datapicker_February";
import datapicker_Fri from "@salesforce/label/c.datapicker_Fri";
import datapicker_Friday from "@salesforce/label/c.datapicker_Friday";
import datapicker_January from "@salesforce/label/c.datapicker_January";
import datapicker_July from "@salesforce/label/c.datapicker_July";
import datapicker_June from "@salesforce/label/c.datapicker_June";
import datapicker_March from "@salesforce/label/c.datapicker_March";
import datapicker_May from "@salesforce/label/c.datapicker_May";
import datapicker_Mon from "@salesforce/label/c.datapicker_Mon";
import datapicker_Monday from "@salesforce/label/c.datapicker_Monday";
import datapicker_NextMonth from "@salesforce/label/c.datapicker_NextMonth";
import datapicker_November from "@salesforce/label/c.datapicker_November";
import datapicker_October from "@salesforce/label/c.datapicker_October";
import datapicker_PreviousMonth from "@salesforce/label/c.datapicker_PreviousMonth";
import datapicker_Sat from "@salesforce/label/c.datapicker_Sat";
import datapicker_Saturday from "@salesforce/label/c.datapicker_Saturday";
import datapicker_September from "@salesforce/label/c.datapicker_September";
import datapicker_Sun from "@salesforce/label/c.datapicker_Sun";
import datapicker_Sunday from "@salesforce/label/c.datapicker_Sunday";
import datapicker_Thu from "@salesforce/label/c.datapicker_Thu";
import datapicker_Thursday from "@salesforce/label/c.datapicker_Thursday";
import datapicker_Tue from "@salesforce/label/c.datapicker_Tue";
import datapicker_Tuesday from "@salesforce/label/c.datapicker_Tuesday";
import datapicker_Wed from "@salesforce/label/c.datapicker_Wed";
import datapicker_Wednesday from "@salesforce/label/c.datapicker_Wednesday";
import email_cc from "@salesforce/label/c.email_cc";
import email_from from "@salesforce/label/c.email_from";
import email_message from "@salesforce/label/c.email_message";
import email_subject from "@salesforce/label/c.email_subject";
import email_to from "@salesforce/label/c.email_to";
import EntitlementId from "@salesforce/label/c.EntitlementId";
import event_cancel from "@salesforce/label/c.event_cancel";
import event_saveEdit from "@salesforce/label/c.event_saveEdit";
import ExistingCases from "@salesforce/label/c.ExistingCases";
import Feedback_Q1 from "@salesforce/label/c.Feedback_Q1";
import Feedback_Q2 from "@salesforce/label/c.Feedback_Q2";
import Feedback_Q3 from "@salesforce/label/c.Feedback_Q3";
import FeedbackResponseAlreadyRegistered from "@salesforce/label/c.FeedbackResponseAlreadyRegistered";
import FeedbackResponseRegistered from "@salesforce/label/c.FeedbackResponseRegistered";
import FeedbackWithoutCase from "@salesforce/label/c.FeedbackWithoutCase";
import FieldCreatorBaseUrl from "@salesforce/label/c.FieldCreatorBaseUrl";
import FieldCreatorBG from "@salesforce/label/c.FieldCreatorBG";
import FieldCreatorCSS from "@salesforce/label/c.FieldCreatorCSS";
import FieldCreatorJSP from "@salesforce/label/c.FieldCreatorJSP";
import FieldCreatorObjectJSP from "@salesforce/label/c.FieldCreatorObjectJSP";
import Find from "@salesforce/label/c.Find";
import GetAllClaims_NumeroSinistro from "@salesforce/label/c.GetAllClaims_NumeroSinistro";
import GetAllClaims_VisualizzaSinistro from "@salesforce/label/c.GetAllClaims_VisualizzaSinistro";
import GLO_ActionColumn from "@salesforce/label/c.GLO_ActionColumn";
import GLO_NoRecordMsg from "@salesforce/label/c.GLO_NoRecordMsg";
import header_closePage from "@salesforce/label/c.header_closePage";
import LABS_SF_AddQuestion from "@salesforce/label/c.LABS_SF_AddQuestion";
import LABS_SF_Anonymous from "@salesforce/label/c.LABS_SF_Anonymous";
import LABS_SF_Answer_as from "@salesforce/label/c.LABS_SF_Answer_as";
import LABS_SF_Cancel from "@salesforce/label/c.LABS_SF_Cancel";
import LABS_SF_Chatter from "@salesforce/label/c.LABS_SF_Chatter";
import LABS_SF_Chatter_Link from "@salesforce/label/c.LABS_SF_Chatter_Link";
import LABS_SF_Community from "@salesforce/label/c.LABS_SF_Community";
import LABS_SF_ContactWithCase from "@salesforce/label/c.LABS_SF_ContactWithCase";
import LABS_SF_CurrentSurveys from "@salesforce/label/c.LABS_SF_CurrentSurveys";
import LABS_SF_Delete from "@salesforce/label/c.LABS_SF_Delete";
import LABS_SF_Delete_Confirm from "@salesforce/label/c.LABS_SF_Delete_Confirm";
import LABS_SF_Edit from "@salesforce/label/c.LABS_SF_Edit";
import LABS_SF_Email_Link_Anonymous from "@salesforce/label/c.LABS_SF_Email_Link_Anonymous";
import LABS_SF_Email_Link_w_Contact_Case_Merge from "@salesforce/label/c.LABS_SF_Email_Link_w_Contact_Case_Merge";
import LABS_SF_Email_Link_w_Contact_Merge from "@salesforce/label/c.LABS_SF_Email_Link_w_Contact_Merge";
import LABS_SF_EnterSurveyName from "@salesforce/label/c.LABS_SF_EnterSurveyName";
import LABS_SF_External_Please_Create_Site from "@salesforce/label/c.LABS_SF_External_Please_Create_Site";
import LABS_SF_For_community_assistance_with_Survey_Force from "@salesforce/label/c.LABS_SF_For_community_assistance_with_Survey_Force";
import LABS_SF_Getting_Help from "@salesforce/label/c.LABS_SF_Getting_Help";
import LABS_SF_HeaderAndThankYou from "@salesforce/label/c.LABS_SF_HeaderAndThankYou";
import LABS_SF_Installation_Guide from "@salesforce/label/c.LABS_SF_Installation_Guide";
import LABS_SF_Internal from "@salesforce/label/c.LABS_SF_Internal";
import LABS_SF_JustContact from "@salesforce/label/c.LABS_SF_JustContact";
import LABS_SF_Learn_More from "@salesforce/label/c.LABS_SF_Learn_More";
import LABS_SF_Make_a_Sample_Survey from "@salesforce/label/c.LABS_SF_Make_a_Sample_Survey";
import LABS_SF_MakeANewSurvey from "@salesforce/label/c.LABS_SF_MakeANewSurvey";
import LABS_SF_MakeNewSurvey from "@salesforce/label/c.LABS_SF_MakeNewSurvey";
import LABS_SF_Next_Steps from "@salesforce/label/c.LABS_SF_Next_Steps";
import LABS_SF_please_visit from "@salesforce/label/c.LABS_SF_please_visit";
import LABS_SF_PleaseEnterTheList from "@salesforce/label/c.LABS_SF_PleaseEnterTheList";
import LABS_SF_Question from "@salesforce/label/c.LABS_SF_Question";
import LABS_SF_Required from "@salesforce/label/c.LABS_SF_Required";
import LABS_SF_RequiredQuestion from "@salesforce/label/c.LABS_SF_RequiredQuestion";
import LABS_SF_Resources from "@salesforce/label/c.LABS_SF_Resources";
import LABS_SF_Results from "@salesforce/label/c.LABS_SF_Results";
import LABS_SF_Salesforce_Answers from "@salesforce/label/c.LABS_SF_Salesforce_Answers";
import LABS_SF_Save from "@salesforce/label/c.LABS_SF_Save";
import LABS_SF_SaveOrder from "@salesforce/label/c.LABS_SF_SaveOrder";
import LABS_SF_SelectQuestionType from "@salesforce/label/c.LABS_SF_SelectQuestionType";
import LABS_SF_SELECTSITE from "@salesforce/label/c.LABS_SF_SELECTSITE";
import LABS_SF_SelectSitetodisplaySurvey from "@salesforce/label/c.LABS_SF_SelectSitetodisplaySurvey";
import LABS_SF_SELECTTYPE from "@salesforce/label/c.LABS_SF_SELECTTYPE";
import LABS_SF_Share from "@salesforce/label/c.LABS_SF_Share";
import LABS_SF_Share_My_Survey from "@salesforce/label/c.LABS_SF_Share_My_Survey";
import LABS_SF_Sharing_Options from "@salesforce/label/c.LABS_SF_Sharing_Options";
import LABS_SF_SubmitSurvey from "@salesforce/label/c.LABS_SF_SubmitSurvey";
import LABS_SF_Survey_Force_is_unsupported from "@salesforce/label/c.LABS_SF_Survey_Force_is_unsupported";
import LABS_SF_Survey_Force_on_Github from "@salesforce/label/c.LABS_SF_Survey_Force_on_Github";
import LABS_SF_Survey_Name_Is_Required from "@salesforce/label/c.LABS_SF_Survey_Name_Is_Required";
import LABS_SF_Survey_Site_Is_Required from "@salesforce/label/c.LABS_SF_Survey_Site_Is_Required";
import LABS_SF_Survey_Submitted_Thank_you from "@salesforce/label/c.LABS_SF_Survey_Submitted_Thank_you";
import LABS_SF_SurveyForceIsOpenSource from "@salesforce/label/c.LABS_SF_SurveyForceIsOpenSource";
import LABS_SF_SurveyURLLink from "@salesforce/label/c.LABS_SF_SurveyURLLink";
import LABS_SF_To_submit_ideas_or_issues from "@salesforce/label/c.LABS_SF_To_submit_ideas_or_issues";
import LABS_SF_User_Guide from "@salesforce/label/c.LABS_SF_User_Guide";
import LABS_SF_View_Results_In_New_Window from "@salesforce/label/c.LABS_SF_View_Results_In_New_Window";
import LABS_SF_View_Sample_Survey from "@salesforce/label/c.LABS_SF_View_Sample_Survey";
import LABS_SF_Welcome_to_Survey_Force from "@salesforce/label/c.LABS_SF_Welcome_to_Survey_Force";
import LABS_SF_X1_Create_a_sample_survey from "@salesforce/label/c.LABS_SF_X1_Create_a_sample_survey";
import LABS_SF_X2_External_Setup_Site from "@salesforce/label/c.LABS_SF_X2_External_Setup_Site";
import LABS_SF_X3_Start_creating_your_first_survey from "@salesforce/label/c.LABS_SF_X3_Start_creating_your_first_survey";
import LABS_SF_You_have_already_taken_this_survey from "@salesforce/label/c.LABS_SF_You_have_already_taken_this_survey";
import LABS_SF_Your_next_few_steps_are_easy from "@salesforce/label/c.LABS_SF_Your_next_few_steps_are_easy";
import lead_header_customer from "@salesforce/label/c.lead_header_customer";
import lead_header_email from "@salesforce/label/c.lead_header_email";
import lead_header_phone from "@salesforce/label/c.lead_header_phone";
import lead_header_source from "@salesforce/label/c.lead_header_source";
import lead_header_statusLead from "@salesforce/label/c.lead_header_statusLead";
import lead_source_advertisement from "@salesforce/label/c.lead_source_advertisement";
import lead_source_agency from "@salesforce/label/c.lead_source_agency";
import lead_source_characterReference from "@salesforce/label/c.lead_source_characterReference";
import lead_source_directContact from "@salesforce/label/c.lead_source_directContact";
import lead_source_employeeReferral from "@salesforce/label/c.lead_source_employeeReferral";
import lead_source_externalList from "@salesforce/label/c.lead_source_externalList";
import lead_source_externalReferral from "@salesforce/label/c.lead_source_externalReferral";
import lead_source_infoMeeting from "@salesforce/label/c.lead_source_infoMeeting";
import lead_source_other from "@salesforce/label/c.lead_source_other";
import lead_source_partner from "@salesforce/label/c.lead_source_partner";
import lead_source_publicRelations from "@salesforce/label/c.lead_source_publicRelations";
import lead_source_purchasedList from "@salesforce/label/c.lead_source_purchasedList";
import lead_source_seminarInternal from "@salesforce/label/c.lead_source_seminarInternal";
import lead_source_seminarPartner from "@salesforce/label/c.lead_source_seminarPartner";
import lead_source_tradeShow from "@salesforce/label/c.lead_source_tradeShow";
import lead_source_web from "@salesforce/label/c.lead_source_web";
import lead_source_Lead_Da_MPS from "@salesforce/label/c.lead_source_Lead_Da_MPS";
import lead_source_wordOfMouth from "@salesforce/label/c.lead_source_wordOfMouth";
import lead_status_appointment from "@salesforce/label/c.lead_status_appointment";
import lead_status_callAgain from "@salesforce/label/c.lead_status_callAgain";
import lead_status_duplicatedLead from "@salesforce/label/c.lead_status_duplicatedLead";
import lead_status_notAnswer from "@salesforce/label/c.lead_status_notAnswer";
import lead_status_notInterested from "@salesforce/label/c.lead_status_notInterested";
import lead_status_toBeProcessed from "@salesforce/label/c.lead_status_toBeProcessed";
import lead_status_wrongContact from "@salesforce/label/c.lead_status_wrongContact";
import leadDetail_columns_createdDate from "@salesforce/label/c.leadDetail_columns_createdDate";
import leadDetail_columns_limitDate from "@salesforce/label/c.leadDetail_columns_limitDate";
import leadDetail_columns_owner from "@salesforce/label/c.leadDetail_columns_owner";
import leadDetail_columns_priority from "@salesforce/label/c.leadDetail_columns_priority";
import leadDetail_columns_prize from "@salesforce/label/c.leadDetail_columns_prize";
import leadDetail_columns_quotationsName from "@salesforce/label/c.leadDetail_columns_quotationsName";
import leadDetail_columns_source from "@salesforce/label/c.leadDetail_columns_source";
import leadDetail_columns_status from "@salesforce/label/c.leadDetail_columns_status";
import leadDetail_columns_subject from "@salesforce/label/c.leadDetail_columns_subject";
import leadDetail_contactHistoryTitle from "@salesforce/label/c.leadDetail_contactHistoryTitle";
import leadDetail_convert from "@salesforce/label/c.leadDetail_convert";
import leadDetail_edit from "@salesforce/label/c.leadDetail_edit";
import leadDetail_event from "@salesforce/label/c.leadDetail_event";
import leadDetail_quotations from "@salesforce/label/c.leadDetail_quotations";
import leadDetail_stockTime from "@salesforce/label/c.leadDetail_stockTime";
import leadDetail_task from "@salesforce/label/c.leadDetail_task";
import leadDetail_timeStock_noData from "@salesforce/label/c.leadDetail_timeStock_noData";
import leadDetail_up from "@salesforce/label/c.leadDetail_up";
import leadDetail_warningDuplicatedLeadConversion_message from "@salesforce/label/c.leadDetail_warningDuplicatedLeadConversion_message";
import leadEdit_alertDuplicatedLead_back from "@salesforce/label/c.leadEdit_alertDuplicatedLead_back";
import leadEdit_alertDuplicatedLead_message from "@salesforce/label/c.leadEdit_alertDuplicatedLead_message";
import leadEdit_cancel from "@salesforce/label/c.leadEdit_cancel";
import leadEdit_noInterestReason from "@salesforce/label/c.leadEdit_noInterestReason";
import leadEdit_ok from "@salesforce/label/c.leadEdit_ok";
import leadEdit_referent from "@salesforce/label/c.leadEdit_referent";
import leadEdit_save from "@salesforce/label/c.leadEdit_save";
import leadEdit_up from "@salesforce/label/c.leadEdit_up";
import leadEdit_warning_title from "@salesforce/label/c.leadEdit_warning_title";
import leadEdit_warningAppointment_back from "@salesforce/label/c.leadEdit_warningAppointment_back";
import leadEdit_warningAppointment_confirmation from "@salesforce/label/c.leadEdit_warningAppointment_confirmation";
import leadEdit_warningAppointment_message from "@salesforce/label/c.leadEdit_warningAppointment_message";
import leadEdit_warningCallAgain_back from "@salesforce/label/c.leadEdit_warningCallAgain_back";
import leadEdit_warningCallAgain_confirmation from "@salesforce/label/c.leadEdit_warningCallAgain_confirmation";
import leadEdit_warningCallAgain_message from "@salesforce/label/c.leadEdit_warningCallAgain_message";
import leadEdit_warningDuplicatedLead_message from "@salesforce/label/c.leadEdit_warningDuplicatedLead_message";
import leadEdit_warningDuplicatedLeadConversion_confirmation from "@salesforce/label/c.leadEdit_warningDuplicatedLeadConversion_confirmation";
import leadEdit_warningToBeProcessed_back from "@salesforce/label/c.leadEdit_warningToBeProcessed_back";
import leadEdit_warningToBeProcessed_confirmation from "@salesforce/label/c.leadEdit_warningToBeProcessed_confirmation";
import leadEdit_warningToBeProcessed_message from "@salesforce/label/c.leadEdit_warningToBeProcessed_message";
import leadEdit_warningWrongContact_message from "@salesforce/label/c.leadEdit_warningWrongContact_message";
import leadEmail_cancel from "@salesforce/label/c.leadEmail_cancel";
import leadEmail_send from "@salesforce/label/c.leadEmail_send";
import LeadLayout_OwnerName from "@salesforce/label/c.LeadLayout_OwnerName";
import LeadLayout_ASADescription from "@salesforce/label/c.LeadLayout_ASADescription";
import LeadLayout_SottoASADescription from "@salesforce/label/c.LeadLayout_SottoASADescription";
import LeadLayout_State from "@salesforce/label/c.LeadLayout_State";
import leadListView_allFilters from "@salesforce/label/c.leadListView_allFilters";
import leadListView_changeOwner from "@salesforce/label/c.leadListView_changeOwner";
import leadListView_columns_aliasOwner from "@salesforce/label/c.leadListView_columns_aliasOwner";
import leadListView_columns_businessName from "@salesforce/label/c.leadListView_columns_businessName";
import leadListView_columns_createdDate from "@salesforce/label/c.leadListView_columns_createdDate";
import leadListView_columns_detailSourceLead from "@salesforce/label/c.leadListView_columns_detailSourceLead";
import leadListView_columns_email from "@salesforce/label/c.leadListView_columns_email";
import leadListView_columns_expirationDate from "@salesforce/label/c.leadListView_columns_expirationDate";
import leadListView_columns_extendedName from "@salesforce/label/c.leadListView_columns_extendedName";
import leadListView_columns_phone from "@salesforce/label/c.leadListView_columns_phone";
import leadListView_columns_sourceLead from "@salesforce/label/c.leadListView_columns_sourceLead";
import leadListView_columns_state from "@salesforce/label/c.leadListView_columns_state";
import leadListView_columns_statusLead from "@salesforce/label/c.leadListView_columns_statusLead";
import leadListView_customLeadOwner from "@salesforce/label/c.leadListView_customLeadOwner";
import leadListView_CodaAgenzia from "@salesforce/label/c.leadListView_CodaAgenzia";
import leadListView_leadList from "@salesforce/label/c.leadListView_leadList";
import leadListView_leadSource from "@salesforce/label/c.leadListView_leadSource";
import leadListView_leadStatus from "@salesforce/label/c.leadListView_leadStatus";
import leadListView_new from "@salesforce/label/c.leadListView_new";
import leadListView_queueManage from "@salesforce/label/c.leadListView_queueManage";
import leadListView_up from "@salesforce/label/c.leadListView_up";
import leadNew_cancel from "@salesforce/label/c.leadNew_cancel";
import leadNew_create from "@salesforce/label/c.leadNew_create";
import leadNew_up from "@salesforce/label/c.leadNew_up";
import leadOwner_cancel from "@salesforce/label/c.leadOwner_cancel";
import leadOwner_changeOwner from "@salesforce/label/c.leadOwner_changeOwner";
import leadOwner_saveEdit from "@salesforce/label/c.leadOwner_saveEdit";
import leadQueue_cancel from "@salesforce/label/c.leadQueue_cancel";
import leadQueue_email from "@salesforce/label/c.leadQueue_email";
import leadQueue_firstName from "@salesforce/label/c.leadQueue_firstName";
import leadQueue_lastName from "@salesforce/label/c.leadQueue_lastName";
import leadQueue_manageQueueAgency from "@salesforce/label/c.leadQueue_manageQueueAgency";
import leadQueue_nodes from "@salesforce/label/c.leadQueue_nodes";
import leadQueue_profileName from "@salesforce/label/c.leadQueue_profileName";
import leadQueue_saveEdit from "@salesforce/label/c.leadQueue_saveEdit";
import leadQueue_userName from "@salesforce/label/c.leadQueue_userName";
import leadQueue_userRoleName from "@salesforce/label/c.leadQueue_userRoleName";
import LOB_ID from "@salesforce/label/c.LOB_ID";
import MakeAsearch from "@salesforce/label/c.MakeAsearch";
import menu_Black_List_Button from "@salesforce/label/c.menu_Black_List_Button";
import menu_Black_List_Href from "@salesforce/label/c.menu_Black_List_Href";
import menu_Svalidazione_Campagne_Button from "@salesforce/label/c.menu_Svalidazione_Campagne_Button";
import menu_Svalidazione_Campagne_href from "@salesforce/label/c.menu_Svalidazione_Campagne_href";
import menu_Dac_Button from "@salesforce/label/c.menu_Dac_Button";
import menu_Dac_Href from "@salesforce/label/c.menu_Dac_Href";
import menu_Dashboard_Button from "@salesforce/label/c.menu_Dashboard_Button";
import menu_Dashboard_Href from "@salesforce/label/c.menu_Dashboard_Href";
import menu_Home_Button from "@salesforce/label/c.menu_Home_Button";
import menu_Home_Href from "@salesforce/label/c.menu_Home_Href";
import menu_Knowledge_Button from "@salesforce/label/c.menu_Knowledge_Button";
import menu_Knowledge_Href from "@salesforce/label/c.menu_Knowledge_Href";
import menu_Monitoraggio_Button from "@salesforce/label/c.menu_Monitoraggio_Button";
import menu_Monitoraggio_Href from "@salesforce/label/c.menu_Monitoraggio_Href";
import menu_Opportunity_Button from "@salesforce/label/c.menu_Opportunity_Button";
import menu_Opportunity_Href from "@salesforce/label/c.menu_Opportunity_Href";
import menu_Report_Button from "@salesforce/label/c.menu_Report_Button";
import menu_Report_Href from "@salesforce/label/c.menu_Report_Href";
import messages_back from "@salesforce/label/c.messages_back";
import messages_close from "@salesforce/label/c.messages_close";
import messages_confirmation from "@salesforce/label/c.messages_confirmation";
import messages_ok from "@salesforce/label/c.messages_ok";
import nbusertodisplay from "@salesforce/label/c.nbusertodisplay";
import NewCase from "@salesforce/label/c.NewCase";
import NFE_AccountPath_Fallback from "@salesforce/label/c.NFE_AccountPath_Fallback";
import NFE_BlackListPath_Fallback from "@salesforce/label/c.NFE_BlackListPath_Fallback";
import NFE_CampaignPath_Fallback from "@salesforce/label/c.NFE_CampaignPath_Fallback";
import NFE_ChiudiCasePath_Fallback from "@salesforce/label/c.NFE_ChiudiCasePath_Fallback";
import NFE_ContactPath_Fallback from "@salesforce/label/c.NFE_ContactPath_Fallback";
import NFE_ENV from "@salesforce/label/c.NFE_ENV";
import NFE_HomePageUrl_Fallback from "@salesforce/label/c.NFE_HomePageUrl_Fallback";
import NFE_KnowledgePath_Fallback from "@salesforce/label/c.NFE_KnowledgePath_Fallback";
import NFE_LeadPath_Fallback from "@salesforce/label/c.NFE_LeadPath_Fallback";
import NFE_MonitoraggioPath_Fallback from "@salesforce/label/c.NFE_MonitoraggioPath_Fallback";
import NFE_OpportunityPath_Fallback from "@salesforce/label/c.NFE_OpportunityPath_Fallback";
import NFE_PrendiInCaricoPath_Fallback from "@salesforce/label/c.NFE_PrendiInCaricoPath_Fallback";
import NoCaseFound from "@salesforce/label/c.NoCaseFound";
import NoClientFound from "@salesforce/label/c.NoClientFound";
import noData_message from "@salesforce/label/c.noData_message";
import NoSubordinateMsg from "@salesforce/label/c.NoSubordinateMsg";
import NoUserSelected from "@salesforce/label/c.NoUserSelected";
import OrgWideEmailDisplayName from "@salesforce/label/c.OrgWideEmailDisplayName";
import OrgWideEmailDisplayNameAAI from "@salesforce/label/c.OrgWideEmailDisplayNameAAI";
import OrgWideEmailDisplayNameAgenziaDipendenti from "@salesforce/label/c.OrgWideEmailDisplayNameAgenziaDipendenti";
import OrgWideEmailDisplayNameMotor from "@salesforce/label/c.OrgWideEmailDisplayNameMotor";
import OrgWideEmailDisplayNameNonMotor from "@salesforce/label/c.OrgWideEmailDisplayNameNonMotor";
import OrgWideEmailDisplayNameQuadra from "@salesforce/label/c.OrgWideEmailDisplayNameQuadra";
import OrgWideEmailDisplayNameReclamo from "@salesforce/label/c.OrgWideEmailDisplayNameReclamo";
import pagination_next from "@salesforce/label/c.pagination_next";
import pagination_previous from "@salesforce/label/c.pagination_previous";
import Passive_Contracts from "@salesforce/label/c.Passive_Contracts";
import Phone_Call_Ids_ID from "@salesforce/label/c.Phone_Call_Ids_ID";
import PKB2_All_Fields_Required from "@salesforce/label/c.PKB2_All_Fields_Required";
import PKB2_Answers_Might_Help from "@salesforce/label/c.PKB2_Answers_Might_Help";
import PKB2_Ask_Button from "@salesforce/label/c.PKB2_Ask_Button";
import PKB2_Back_To_Results from "@salesforce/label/c.PKB2_Back_To_Results";
import PKB2_Back_To_Search_Page from "@salesforce/label/c.PKB2_Back_To_Search_Page";
import PKB2_Cancel from "@salesforce/label/c.PKB2_Cancel";
import PKB2_Case_Error_Admin_Notification from "@salesforce/label/c.PKB2_Case_Error_Admin_Notification";
import PKB2_Case_Submit_Error from "@salesforce/label/c.PKB2_Case_Submit_Error";
import PKB2_Category_Group_Label_1 from "@salesforce/label/c.PKB2_Category_Group_Label_1";
import PKB2_Category_Group_Label_2 from "@salesforce/label/c.PKB2_Category_Group_Label_2";
import PKB2_Category_Group_Label_3 from "@salesforce/label/c.PKB2_Category_Group_Label_3";
import PKB2_Close_Window from "@salesforce/label/c.PKB2_Close_Window";
import PKB2_Complete_Request from "@salesforce/label/c.PKB2_Complete_Request";
import PKB2_Contact_Us from "@salesforce/label/c.PKB2_Contact_Us";
import PKB2_Contact_Us_Link_Prompt from "@salesforce/label/c.PKB2_Contact_Us_Link_Prompt";
import PKB2_Contact_Us_Prompt from "@salesforce/label/c.PKB2_Contact_Us_Prompt";
import PKB2_Create_Settings from "@salesforce/label/c.PKB2_Create_Settings";
import PKB2_Email from "@salesforce/label/c.PKB2_Email";
import PKB2_Email_Article from "@salesforce/label/c.PKB2_Email_Article";
import PKB2_Email_Invalid from "@salesforce/label/c.PKB2_Email_Invalid";
import PKB2_Error_Admin_Notification_Email from "@salesforce/label/c.PKB2_Error_Admin_Notification_Email";
import PKB2_Featured_Articles from "@salesforce/label/c.PKB2_Featured_Articles";
import PKB2_Feedback from "@salesforce/label/c.PKB2_Feedback";
import PKB2_Feedback_Appreciated from "@salesforce/label/c.PKB2_Feedback_Appreciated";
import PKB2_Feedback_Characters_Remaining from "@salesforce/label/c.PKB2_Feedback_Characters_Remaining";
import PKB2_First_Name from "@salesforce/label/c.PKB2_First_Name";
import PKB2_Last_Name from "@salesforce/label/c.PKB2_Last_Name";
import PKB2_More_Useful from "@salesforce/label/c.PKB2_More_Useful";
import PKB2_Narrow_Search from "@salesforce/label/c.PKB2_Narrow_Search";
import PKB2_Next_Link from "@salesforce/label/c.PKB2_Next_Link";
import PKB2_No_Filter from "@salesforce/label/c.PKB2_No_Filter";
import PKB2_No_Found_Answer from "@salesforce/label/c.PKB2_No_Found_Answer";
import PKB2_No_Results from "@salesforce/label/c.PKB2_No_Results";
import PKB2_No_Settings_Yet from "@salesforce/label/c.PKB2_No_Settings_Yet";
import PKB2_None from "@salesforce/label/c.PKB2_None";
import PKB2_Popular_Articles from "@salesforce/label/c.PKB2_Popular_Articles";
import PKB2_Previous_Link from "@salesforce/label/c.PKB2_Previous_Link";
import PKB2_Printable_View from "@salesforce/label/c.PKB2_Printable_View";
import PKB2_Recommended from "@salesforce/label/c.PKB2_Recommended";
import PKB2_Related_Articles from "@salesforce/label/c.PKB2_Related_Articles";
import PKB2_Request_Submitted from "@salesforce/label/c.PKB2_Request_Submitted";
import PKB2_Request_Type from "@salesforce/label/c.PKB2_Request_Type";
import PKB2_Reset_Search from "@salesforce/label/c.PKB2_Reset_Search";
import PKB2_Search_Button from "@salesforce/label/c.PKB2_Search_Button";
import PKB2_Search_Prompt from "@salesforce/label/c.PKB2_Search_Prompt";
import PKB2_Search_Results from "@salesforce/label/c.PKB2_Search_Results";
import PKB2_Select_Settings from "@salesforce/label/c.PKB2_Select_Settings";
import PKB2_Still_Have_Question from "@salesforce/label/c.PKB2_Still_Have_Question";
import PKB2_Submit from "@salesforce/label/c.PKB2_Submit";
import PKB2_Subscribe_Article_Feed from "@salesforce/label/c.PKB2_Subscribe_Article_Feed";
import PKB2_Subscribe_Feed_Results from "@salesforce/label/c.PKB2_Subscribe_Feed_Results";
import PKB2_Thanks_For_Feedback from "@salesforce/label/c.PKB2_Thanks_For_Feedback";
import PKB2_Tweet_This from "@salesforce/label/c.PKB2_Tweet_This";
import PKB2_Value_Must_Match_Name from "@salesforce/label/c.PKB2_Value_Must_Match_Name";
import PKB2_Was_Helpful from "@salesforce/label/c.PKB2_Was_Helpful";
import PKB2_Within_Category from "@salesforce/label/c.PKB2_Within_Category";
import PKB2_Yes_Submit_Question from "@salesforce/label/c.PKB2_Yes_Submit_Question";
import PKB2_You_Searched_For from "@salesforce/label/c.PKB2_You_Searched_For";
import PositiveFeebgckNotificationMsf from "@salesforce/label/c.PositiveFeebgckNotificationMsf";
import QueryActiveUsers from "@salesforce/label/c.QueryActiveUsers";
import reCAPTCHAbaseURL from "@salesforce/label/c.reCAPTCHAbaseURL";
import reCAPTCHAChallengeLink from "@salesforce/label/c.reCAPTCHAChallengeLink";
import reCAPTCHANoScriptLink from "@salesforce/label/c.reCAPTCHANoScriptLink";
import reCAPTCHAprivateKey from "@salesforce/label/c.reCAPTCHAprivateKey";
import reCAPTCHApublicKey from "@salesforce/label/c.reCAPTCHApublicKey";
import Save from "@salesforce/label/c.Save";
import SaveAndNew from "@salesforce/label/c.SaveAndNew";
import Search from "@salesforce/label/c.Search";
import Select from "@salesforce/label/c.Select";
import Select1 from "@salesforce/label/c.Select1";
import SiteDomain from "@salesforce/label/c.SiteDomain";
import task_cancel from "@salesforce/label/c.task_cancel";
import task_completed from "@salesforce/label/c.task_completed";
import task_informationReceived from "@salesforce/label/c.task_informationReceived";
import task_inProgress from "@salesforce/label/c.task_inProgress";
import task_label_highPriority from "@salesforce/label/c.task_label_highPriority";
import task_open from "@salesforce/label/c.task_open";
import task_outOfTime from "@salesforce/label/c.task_outOfTime";
import task_pending from "@salesforce/label/c.task_pending";
import task_pendingFreakIt from "@salesforce/label/c.task_pendingFreakIt";
import task_saveEdit from "@salesforce/label/c.task_saveEdit";
import task_task from "@salesforce/label/c.task_task";
import TaskCreated from "@salesforce/label/c.TaskCreated";
import Tsk_Closed from "@salesforce/label/c.Tsk_Closed";
import unauthorized_message from "@salesforce/label/c.unauthorized_message";
import unauthorized_title from "@salesforce/label/c.unauthorized_title";
import Update_Rule from "@salesforce/label/c.Update_Rule";
import UpdatePhoneAndNewCase from "@salesforce/label/c.UpdatePhoneAndNewCase";
import uploadFile_attachments from "@salesforce/label/c.uploadFile_attachments";
import uploadFile_upload from "@salesforce/label/c.uploadFile_upload";
import vfc06_AgentNotRecognized from "@salesforce/label/c.vfc06_AgentNotRecognized";
import VFC06_CaseLightCreated from "@salesforce/label/c.VFC06_CaseLightCreated";
import VFC06_CaseLightNotCreated from "@salesforce/label/c.VFC06_CaseLightNotCreated";
import VFC06_CreateCustomer from "@salesforce/label/c.VFC06_CreateCustomer";
import vfc06_NoAgents from "@salesforce/label/c.vfc06_NoAgents";
import vfc06_NoAgentsInputs from "@salesforce/label/c.vfc06_NoAgentsInputs";
import VFC06_TraceCaseLight from "@salesforce/label/c.VFC06_TraceCaseLight";
import VFC07_DocumentName from "@salesforce/label/c.VFC07_DocumentName";
import VFC07_MissingDocumentEmailSubject from "@salesforce/label/c.VFC07_MissingDocumentEmailSubject";
import VFC07_MissingDocumentList from "@salesforce/label/c.VFC07_MissingDocumentList";
import VFC07_NoDocuments from "@salesforce/label/c.VFC07_NoDocuments";
import VFC07_NoSubCategory from "@salesforce/label/c.VFC07_NoSubCategory";
import VFC07_SendEmail from "@salesforce/label/c.VFC07_SendEmail";
import VFP01_2ndSupportType from "@salesforce/label/c.VFP01_2ndSupportType";
import VFP01_CreateTasks from "@salesforce/label/c.VFP01_CreateTasks";
import VFP01_TaskCreation from "@salesforce/label/c.VFP01_TaskCreation";
import VFP06_AAI_Agent from "@salesforce/label/c.VFP06_AAI_Agent";
import VFP06_AAIAgents from "@salesforce/label/c.VFP06_AAIAgents";
import VFP06_AAICustomer from "@salesforce/label/c.VFP06_AAICustomer";
import VFP06_AMFCustomer from "@salesforce/label/c.VFP06_AMFCustomer";
import VFP06_AMPSCustomer from "@salesforce/label/c.VFP06_AMPSCustomer";
import VFP06_Bank_Agent from "@salesforce/label/c.VFP06_Bank_Agent";
import VFP06_CalledNumber from "@salesforce/label/c.VFP06_CalledNumber";
import VFP06_CalledNumber_AAI from "@salesforce/label/c.VFP06_CalledNumber_AAI";
import VFP06_CalledNumber_AMF from "@salesforce/label/c.VFP06_CalledNumber_AMF";
import VFP06_CalledNumber_AMPS from "@salesforce/label/c.VFP06_CalledNumber_AMPS";
import VFP06_CalledNumber_Quadra from "@salesforce/label/c.VFP06_CalledNumber_Quadra";
import VFP06_CreateNewCase from "@salesforce/label/c.VFP06_CreateNewCase";
import VFP06_CustTypology from "@salesforce/label/c.VFP06_CustTypology";
import VFP06_Family_Protect from "@salesforce/label/c.VFP06_Family_Protect";
import VFP06_InactiveAgent from "@salesforce/label/c.VFP06_InactiveAgent";
import VFP06_MissingAddress from "@salesforce/label/c.VFP06_MissingAddress";
import VFP06_MissingContactMsg from "@salesforce/label/c.VFP06_MissingContactMsg";
import VFP06_MissingEmail from "@salesforce/label/c.VFP06_MissingEmail";
import VFP06_MissingPhone from "@salesforce/label/c.VFP06_MissingPhone";
import VFP06_ModifyCustomer from "@salesforce/label/c.VFP06_ModifyCustomer";
import VFP06_Multiple_Bank_Agents from "@salesforce/label/c.VFP06_Multiple_Bank_Agents";
import VFP06_NoResultFound from "@salesforce/label/c.VFP06_NoResultFound";
import VFP06_SearchedCaseNotFound from "@salesforce/label/c.VFP06_SearchedCaseNotFound";
import VFP06_ViewClaims from "@salesforce/label/c.VFP06_ViewClaims";
import VFP08_BirthDate from "@salesforce/label/c.VFP08_BirthDate";
import VFP08_FillSearch from "@salesforce/label/c.VFP08_FillSearch";
import VFP08_LastName from "@salesforce/label/c.VFP08_LastName";
import VFP08_OverwriteEmail from "@salesforce/label/c.VFP08_OverwriteEmail";
import VFP08_Successful from "@salesforce/label/c.VFP08_Successful";
import VFP11_Action_Performed from "@salesforce/label/c.VFP11_Action_Performed";
import VFP11_Associated_Account from "@salesforce/label/c.VFP11_Associated_Account";
import VFP11_Associated_Policies from "@salesforce/label/c.VFP11_Associated_Policies";
import VFP11_Link_Policy_to_Case from "@salesforce/label/c.VFP11_Link_Policy_to_Case";
import VFP11_Missing_Account from "@salesforce/label/c.VFP11_Missing_Account";
import VFP11_No_Policies_Found from "@salesforce/label/c.VFP11_No_Policies_Found";
import VFP12_Existing_rule from "@salesforce/label/c.VFP12_Existing_rule";
import VFP12_Existing_rule_end from "@salesforce/label/c.VFP12_Existing_rule_end";
import VFP12_No_Email_Selected from "@salesforce/label/c.VFP12_No_Email_Selected";
import VFP12_Page_Sub_Title from "@salesforce/label/c.VFP12_Page_Sub_Title";
import VFP12_Page_Title from "@salesforce/label/c.VFP12_Page_Title";
import VFP12_Two_Emails_Not_allowed from "@salesforce/label/c.VFP12_Two_Emails_Not_allowed";
import VFP13_Attach_Article from "@salesforce/label/c.VFP13_Attach_Article";
import VFP13_No_Article from "@salesforce/label/c.VFP13_No_Article";
import VFP13_Table_Header from "@salesforce/label/c.VFP13_Table_Header";
import VFP14_Email_Address from "@salesforce/label/c.VFP14_Email_Address";
import VFP14_Email_Request_GDPR_Assistance from "@salesforce/label/c.VFP14_Email_Request_GDPR_Assistance";
import VFP14_Email_to_AAI_Agent from "@salesforce/label/c.VFP14_Email_to_AAI_Agent";
import VFP14_Email_to_Agency from "@salesforce/label/c.VFP14_Email_to_Agency";
import VFP14_Email_to_Agent from "@salesforce/label/c.VFP14_Email_to_Agent";
import VFP14_Email_to_Blue_Ass from "@salesforce/label/c.VFP14_Email_to_Blue_Ass";
import VFP14_Email_to_Customer from "@salesforce/label/c.VFP14_Email_to_Customer";
import VFP14_Email_To_IPSI from "@salesforce/label/c.VFP14_Email_To_IPSI";
import VFP14_Email_to_My_Fox from "@salesforce/label/c.VFP14_Email_to_My_Fox";
import VFP14_Email_to_Technical_Office from "@salesforce/label/c.VFP14_Email_to_Technical_Office";
import VFP14_IncomingEmail from "@salesforce/label/c.VFP14_IncomingEmail";
import VFP14_Next from "@salesforce/label/c.VFP14_Next";
import VFP14_NoEmail from "@salesforce/label/c.VFP14_NoEmail";
import VFP14_Of from "@salesforce/label/c.VFP14_Of";
import VFP14_Outbound_Email from "@salesforce/label/c.VFP14_Outbound_Email";
import VFP14_Page from "@salesforce/label/c.VFP14_Page";
import VFP14_Previous from "@salesforce/label/c.VFP14_Previous";
import VFP14_SendAnEmail from "@salesforce/label/c.VFP14_SendAnEmail";
import VFP15_AutomaticTaskSection from "@salesforce/label/c.VFP15_AutomaticTaskSection";
import VFP15_CaseTypologySection from "@salesforce/label/c.VFP15_CaseTypologySection";
import VFP15_RuleAlreadyExists from "@salesforce/label/c.VFP15_RuleAlreadyExists";
import VFP15_RuleHasBeenCreated from "@salesforce/label/c.VFP15_RuleHasBeenCreated";
import VFP15_RuleHasBeenUpdated from "@salesforce/label/c.VFP15_RuleHasBeenUpdated";
import VFP15_RuleNotCreated from "@salesforce/label/c.VFP15_RuleNotCreated";
import VFP15_RuleNotUpdated from "@salesforce/label/c.VFP15_RuleNotUpdated";
import VFP15_Sub_Title from "@salesforce/label/c.VFP15_Sub_Title";
import VFP15_TechnicalOfficeNotAvailable from "@salesforce/label/c.VFP15_TechnicalOfficeNotAvailable";
import VFP15_Title from "@salesforce/label/c.VFP15_Title";
import VFP15_UserSelectionSection from "@salesforce/label/c.VFP15_UserSelectionSection";
import VFP15_UsersNotAvailable from "@salesforce/label/c.VFP15_UsersNotAvailable";
import VFP16_Button_not_available from "@salesforce/label/c.VFP16_Button_not_available";
import VFP16_Missing_Inputs from "@salesforce/label/c.VFP16_Missing_Inputs";
import VFP17_Content_Missing from "@salesforce/label/c.VFP17_Content_Missing";
import VFP17_Message_Content from "@salesforce/label/c.VFP17_Message_Content";
import VFP17_Mobile_Selection from "@salesforce/label/c.VFP17_Mobile_Selection";
import VFP17_No_Account from "@salesforce/label/c.VFP17_No_Account";
import VFP17_No_Mobile from "@salesforce/label/c.VFP17_No_Mobile";
import VFP17_Page_Label from "@salesforce/label/c.VFP17_Page_Label";
import VFP17_PageSubTitle from "@salesforce/label/c.VFP17_PageSubTitle";
import VFP17_PageTitle from "@salesforce/label/c.VFP17_PageTitle";
import VFP17_Send_SMS from "@salesforce/label/c.VFP17_Send_SMS";
import VFP17_SMS_Not_Sent from "@salesforce/label/c.VFP17_SMS_Not_Sent";
import VFP17_SMS_Sent from "@salesforce/label/c.VFP17_SMS_Sent";
import VFP17_Template_Selection from "@salesforce/label/c.VFP17_Template_Selection";
import VFP19_InsertRequestSubject from "@salesforce/label/c.VFP19_InsertRequestSubject";
import VFP19_OutOfOfficeMsg from "@salesforce/label/c.VFP19_OutOfOfficeMsg";
import VFP19_SelectCategory from "@salesforce/label/c.VFP19_SelectCategory";
import VFP19_SelectSubCategory from "@salesforce/label/c.VFP19_SelectSubCategory";
import VFP19_StartChat from "@salesforce/label/c.VFP19_StartChat";
import VFP19_SubTitle from "@salesforce/label/c.VFP19_SubTitle";
import VFP19_Title from "@salesforce/label/c.VFP19_Title";
import VFP23_SearchAndSendTaskToAgent from "@salesforce/label/c.VFP23_SearchAndSendTaskToAgent";
import VFP24_AssociateAgent from "@salesforce/label/c.VFP24_AssociateAgent";
import VFP24_SearchAndSendTaskToAgent from "@salesforce/label/c.VFP24_SearchAndSendTaskToAgent";
import VFP25_SearchAndSendTaskToLead from "@salesforce/label/c.VFP25_SearchAndSendTaskToLead";
import VFP31_ShowClaims from "@salesforce/label/c.VFP31_ShowClaims";
import ViewCase from "@salesforce/label/c.ViewCase";
import QuotationStatus from "@salesforce/label/c.QuotationStatus";
import menu_Riforma_2024_Button from "@salesforce/label/c.menu_Riforma_2024_Button";
import menu_Riforma_2024_href from "@salesforce/label/c.menu_Riforma_2024_href";

export default class MobilityLabels {
    static label = {
        Active_Contracts,
        Agency,
        AgencyONE,
        Agent_View,
        AgentNameAutoFilled,
        Attachment_loading_block,
        B2B_Insurance_Line_Page_Activity,
        B2B_Insurance_Line_Page_Car,
        B2B_Insurance_Line_Page_HealthCare,
        B2B_Insurance_Line_Page_Other,
        B2B_Insurance_Line_Page_Other_Businesses,
        blacklist_accidents,
        blacklist_broker,
        blacklist_car,
        blacklist_commercial,
        blacklist_companies,
        blacklist_disease,
        blacklist_dwelling,
        blacklist_include_all_campaigns,
        blacklist_last_edit,
        blacklist_protection,
        blacklist_renewal,
        blacklist_save,
        blacklist_save_failed,
        blacklist_save_success,
        blacklist_saving,
        blacklist_service,
        campaign_aborted,
        campaign_colNumber_customer,
        campaign_colNumber_customers,
        campaign_colNumber_noCustomer,
        campaign_completed,
        campaign_legend_agency,
        campaign_legend_managementAXA,
        campaign_onGoing,
        campaign_planned,
        campaign_priority_prior,
        campaign_priority_prioritary,
        campaignCounters_activities,
        campaignCounters_activityHistory,
        campaignCounters_history,
        campaignCounters_negotiations,
        campaignCounters_onGoingNegotiations,
        campaignCounters_openActivities,
        campaignCounters_opportunity,
        campaignDetail_agency,
        campaignDetail_alert,
        campaignDetail_attached,
        campaignDetail_attachedName,
        campaignDetail_collaborator,
        campaignDetail_customerTitle,
        campaignDetail_edit,
        campaignDetail_moreInfo,
        campaignDetail_negotiationsCreatedPercentage,
        campaignDetail_negotiationsWon,
        campaignDetail_negotiationsWonEuro,
        campaignDetail_negotiationsWonPercentage,
        campaignDetail_priority_prior,
        campaignDetail_priority_prioritary,
        campaignDetail_processing,
        campaignDetail_targetCustomer,
        campaignDetail_targetCustomers,
        campaignDetail_title,
        campaignDetail_up,
        campaignDetail_upload,
        campaignDetail_worked,
        campaignDetail_workedCustomer,
        campaignDetail_workedCustomerPercentage,
        campaignDetail_workedPlur,
        campaignEdit_cancel,
        campaignEdit_save,
        CampaignLayout_CreatedByName,
        CampaignLayout_LastModifiedByName,
        CampaignLayout_OwnerName,
        CampaignLayout_ParentName,
        CampaignLayout_RecordTypeName,
        campaignListPage_campaignList,
        campaignListPage_endDate,
        campaignListPage_name,
        campaignListPage_new,
        campaignListPage_refresh,
        campaignListPage_startDate,
        campaignListPage_status,
        campaignListPage_statusCampaign,
        campaignListPage_type,
        campaignNew_cancel,
        campaignNew_create,
        campaignProcessing_allFilters_ownerTwo,
        campaignProcessing_allFilters,
        campaignProcessing_apply,
        campaignProcessing_assigns,
        campaignProcessing_back,
        campaignProcessing_campaignProcessing,
        campaignProcessing_exclude,
        campaignProcessing_resetFilters,
        campaignProcessing_update,
        campaignSmsEmailDeliveredEmail,
        campaignSmsEmailDeliveredSms,
        campaignSmsEmailLabel,
        campaignSmsEmailNotDeliveredPercentage,
        campaignSmsEmailOpeningPercentage,
        campaignSmsEmailPriorityCustomersPercentage,
        campaignSmsEmailSent,
        campaignStatus_Aborted,
        campaignStatus_Completed,
        campaignStatus_Ongoing,
        campaignStatus_Planned,
        Cancel,
        case_header_category,
        case_header_date,
        case_header_description,
        case_header_status,
        case_header_subcategory,
        case_status_agentInfoReceived,
        case_status_forwardingToBusinessLine,
        case_status_forwardingToIT,
        case_status_inManagementAtHD3,
        case_status_inSpecialistManagement,
        case_status_open,
        case_status_solutionOffer,
        case_status_solutionRejected,
        case_status_specialistResponse,
        case_status_takenOver,
        case_status_waitingAgentInfo,
        Categoria_ID,
        ChangeOwnerValidationMessageNMA,
        ChngOwnValidMsgNMAContabilita,
        ChooseACase,
        ChooseAClient,
        Client,
        ClientONE,
        ClosedCaseTaskNoneClosedError,
        closeTheLoop_feedback,
        contactHistory_flag_flagMouseoverBounce,
        contactHistory_flag_flagMouseoverClick,
        contactHistory_flag_flagMouseoverOpen,
        contactHistory_flag_flagMouseoverSent,
        contactHistory_heading_date,
        contactHistory_heading_typeOfInteraction,
        contactHistory_status_bounce,
        contactHistory_status_click,
        contactHistory_status_open,
        contactHistory_status_sent,
        Create,
        create_new_case,
        CreateNewCase,
        CreateRule,
        customerCampaign_endDate_expires,
        customerCampaign_status_excluding,
        customerCampaign_status_inCampaign,
        customerCampaign_status_infoRequest,
        customerCampaign_status_inPreparation,
        customerCampaign_status_interested,
        customerCampaign_status_noAnswer,
        customerCampaign_status_noInterested,
        customerCampaign_status_toAssign,
        customerCampaign_status_toContact,
        customerCampaign_status_toRecontact,
        customerCampaign_status_toWork,
        customerCampaign_status_worked,
        customerCampaign_status_wrongContact,
        customerCampaign_type_agency,
        customerCampaign_type_campaignManagement,
        CustomerView,
        dataGrid_of,
        dataGrid_results,
        dataGrid_selected,
        dataGrid_update,
        datapicker_April,
        datapicker_August,
        datapicker_December,
        datapicker_February,
        datapicker_Fri,
        datapicker_Friday,
        datapicker_January,
        datapicker_July,
        datapicker_June,
        datapicker_March,
        datapicker_May,
        datapicker_Mon,
        datapicker_Monday,
        datapicker_NextMonth,
        datapicker_November,
        datapicker_October,
        datapicker_PreviousMonth,
        datapicker_Sat,
        datapicker_Saturday,
        datapicker_September,
        datapicker_Sun,
        datapicker_Sunday,
        datapicker_Thu,
        datapicker_Thursday,
        datapicker_Tue,
        datapicker_Tuesday,
        datapicker_Wed,
        datapicker_Wednesday,
        email_cc,
        email_from,
        email_message,
        email_subject,
        email_to,
        EntitlementId,
        event_cancel,
        event_saveEdit,
        ExistingCases,
        Feedback_Q1,
        Feedback_Q2,
        Feedback_Q3,
        FeedbackResponseAlreadyRegistered,
        FeedbackResponseRegistered,
        FeedbackWithoutCase,
        FieldCreatorBaseUrl,
        FieldCreatorBG,
        FieldCreatorCSS,
        FieldCreatorJSP,
        FieldCreatorObjectJSP,
        Find,
        GetAllClaims_NumeroSinistro,
        GetAllClaims_VisualizzaSinistro,
        GLO_ActionColumn,
        GLO_NoRecordMsg,
        header_closePage,
        LABS_SF_AddQuestion,
        LABS_SF_Anonymous,
        LABS_SF_Answer_as,
        LABS_SF_Cancel,
        LABS_SF_Chatter,
        LABS_SF_Chatter_Link,
        LABS_SF_Community,
        LABS_SF_ContactWithCase,
        LABS_SF_CurrentSurveys,
        LABS_SF_Delete,
        LABS_SF_Delete_Confirm,
        LABS_SF_Edit,
        LABS_SF_Email_Link_Anonymous,
        LABS_SF_Email_Link_w_Contact_Case_Merge,
        LABS_SF_Email_Link_w_Contact_Merge,
        LABS_SF_EnterSurveyName,
        LABS_SF_External_Please_Create_Site,
        LABS_SF_For_community_assistance_with_Survey_Force,
        LABS_SF_Getting_Help,
        LABS_SF_HeaderAndThankYou,
        LABS_SF_Installation_Guide,
        LABS_SF_Internal,
        LABS_SF_JustContact,
        LABS_SF_Learn_More,
        LABS_SF_Make_a_Sample_Survey,
        LABS_SF_MakeANewSurvey,
        LABS_SF_MakeNewSurvey,
        LABS_SF_Next_Steps,
        LABS_SF_please_visit,
        LABS_SF_PleaseEnterTheList,
        LABS_SF_Question,
        LABS_SF_Required,
        LABS_SF_RequiredQuestion,
        LABS_SF_Resources,
        LABS_SF_Results,
        LABS_SF_Salesforce_Answers,
        LABS_SF_Save,
        LABS_SF_SaveOrder,
        LABS_SF_SelectQuestionType,
        LABS_SF_SELECTSITE,
        LABS_SF_SelectSitetodisplaySurvey,
        LABS_SF_SELECTTYPE,
        LABS_SF_Share,
        LABS_SF_Share_My_Survey,
        LABS_SF_Sharing_Options,
        LABS_SF_SubmitSurvey,
        LABS_SF_Survey_Force_is_unsupported,
        LABS_SF_Survey_Force_on_Github,
        LABS_SF_Survey_Name_Is_Required,
        LABS_SF_Survey_Site_Is_Required,
        LABS_SF_Survey_Submitted_Thank_you,
        LABS_SF_SurveyForceIsOpenSource,
        LABS_SF_SurveyURLLink,
        LABS_SF_To_submit_ideas_or_issues,
        LABS_SF_User_Guide,
        LABS_SF_View_Results_In_New_Window,
        LABS_SF_View_Sample_Survey,
        LABS_SF_Welcome_to_Survey_Force,
        LABS_SF_X1_Create_a_sample_survey,
        LABS_SF_X2_External_Setup_Site,
        LABS_SF_X3_Start_creating_your_first_survey,
        LABS_SF_You_have_already_taken_this_survey,
        LABS_SF_Your_next_few_steps_are_easy,
        lead_header_customer,
        lead_header_email,
        lead_header_phone,
        lead_header_source,
        lead_header_statusLead,
        lead_source_advertisement,
        lead_source_agency,
        lead_source_characterReference,
        lead_source_directContact,
        lead_source_employeeReferral,
        lead_source_externalList,
        lead_source_externalReferral,
        lead_source_infoMeeting,
        lead_source_other,
        lead_source_partner,
        lead_source_publicRelations,
        lead_source_purchasedList,
        lead_source_seminarInternal,
        lead_source_seminarPartner,
        lead_source_tradeShow,
        lead_source_web,
        lead_source_Lead_Da_MPS,
        lead_source_wordOfMouth,
        lead_status_appointment,
        lead_status_callAgain,
        lead_status_duplicatedLead,
        lead_status_notAnswer,
        lead_status_notInterested,
        lead_status_toBeProcessed,
        lead_status_wrongContact,
        leadDetail_columns_createdDate,
        leadDetail_columns_limitDate,
        leadDetail_columns_owner,
        leadDetail_columns_priority,
        leadDetail_columns_prize,
        leadDetail_columns_quotationsName,
        leadDetail_columns_source,
        leadDetail_columns_status,
        leadDetail_columns_subject,
        leadDetail_contactHistoryTitle,
        leadDetail_convert,
        leadDetail_edit,
        leadDetail_event,
        leadDetail_quotations,
        leadDetail_stockTime,
        leadDetail_task,
        leadDetail_timeStock_noData,
        leadDetail_up,
        leadDetail_warningDuplicatedLeadConversion_message,
        leadEdit_alertDuplicatedLead_back,
        leadEdit_alertDuplicatedLead_message,
        leadEdit_cancel,
        leadEdit_noInterestReason,
        leadEdit_ok,
        leadEdit_referent,
        leadEdit_save,
        leadEdit_up,
        leadEdit_warning_title,
        leadEdit_warningAppointment_back,
        leadEdit_warningAppointment_confirmation,
        leadEdit_warningAppointment_message,
        leadEdit_warningCallAgain_back,
        leadEdit_warningCallAgain_confirmation,
        leadEdit_warningCallAgain_message,
        leadEdit_warningDuplicatedLead_message,
        leadEdit_warningDuplicatedLeadConversion_confirmation,
        leadEdit_warningToBeProcessed_back,
        leadEdit_warningToBeProcessed_confirmation,
        leadEdit_warningToBeProcessed_message,
        leadEdit_warningWrongContact_message,
        leadEmail_cancel,
        leadEmail_send,
        LeadLayout_OwnerName,
        LeadLayout_ASADescription,
        LeadLayout_SottoASADescription,
        LeadLayout_State,
        leadListView_allFilters,
        leadListView_changeOwner,
        leadListView_columns_aliasOwner,
        leadListView_columns_businessName,
        leadListView_columns_createdDate,
        leadListView_columns_detailSourceLead,
        leadListView_columns_email,
        leadListView_columns_expirationDate,
        leadListView_columns_extendedName,
        leadListView_columns_phone,
        leadListView_columns_sourceLead,
        leadListView_columns_state,
        leadListView_columns_statusLead,
        leadListView_customLeadOwner,
        leadListView_CodaAgenzia,
        leadListView_leadList,
        leadListView_leadSource,
        leadListView_leadStatus,
        leadListView_new,
        leadListView_queueManage,
        leadListView_up,
        leadNew_cancel,
        leadNew_create,
        leadNew_up,
        leadOwner_cancel,
        leadOwner_changeOwner,
        leadOwner_saveEdit,
        leadQueue_cancel,
        leadQueue_email,
        leadQueue_firstName,
        leadQueue_lastName,
        leadQueue_manageQueueAgency,
        leadQueue_nodes,
        leadQueue_profileName,
        leadQueue_saveEdit,
        leadQueue_userName,
        leadQueue_userRoleName,
        LOB_ID,
        MakeAsearch,
        menu_Black_List_Button,
        menu_Black_List_Href,
        menu_Svalidazione_Campagne_Button,
        menu_Svalidazione_Campagne_href,
        menu_Dac_Button,
        menu_Dac_Href,
        menu_Dashboard_Button,
        menu_Dashboard_Href,
        menu_Home_Button,
        menu_Home_Href,
        menu_Knowledge_Button,
        menu_Knowledge_Href,
        menu_Monitoraggio_Button,
        menu_Monitoraggio_Href,
        menu_Opportunity_Button,
        menu_Opportunity_Href,
        menu_Report_Button,
        menu_Report_Href,
        messages_back,
        messages_close,
        messages_confirmation,
        messages_ok,
        nbusertodisplay,
        NewCase,
        NFE_AccountPath_Fallback,
        NFE_BlackListPath_Fallback,
        NFE_CampaignPath_Fallback,
        NFE_ChiudiCasePath_Fallback,
        NFE_ContactPath_Fallback,
        NFE_ENV,
        NFE_HomePageUrl_Fallback,
        NFE_KnowledgePath_Fallback,
        NFE_LeadPath_Fallback,
        NFE_MonitoraggioPath_Fallback,
        NFE_OpportunityPath_Fallback,
        NFE_PrendiInCaricoPath_Fallback,
        NoCaseFound,
        NoClientFound,
        noData_message,
        NoSubordinateMsg,
        NoUserSelected,
        OrgWideEmailDisplayName,
        OrgWideEmailDisplayNameAAI,
        OrgWideEmailDisplayNameAgenziaDipendenti,
        OrgWideEmailDisplayNameMotor,
        OrgWideEmailDisplayNameNonMotor,
        OrgWideEmailDisplayNameQuadra,
        OrgWideEmailDisplayNameReclamo,
        pagination_next,
        pagination_previous,
        Passive_Contracts,
        Phone_Call_Ids_ID,
        PKB2_All_Fields_Required,
        PKB2_Answers_Might_Help,
        PKB2_Ask_Button,
        PKB2_Back_To_Results,
        PKB2_Back_To_Search_Page,
        PKB2_Cancel,
        PKB2_Case_Error_Admin_Notification,
        PKB2_Case_Submit_Error,
        PKB2_Category_Group_Label_1,
        PKB2_Category_Group_Label_2,
        PKB2_Category_Group_Label_3,
        PKB2_Close_Window,
        PKB2_Complete_Request,
        PKB2_Contact_Us,
        PKB2_Contact_Us_Link_Prompt,
        PKB2_Contact_Us_Prompt,
        PKB2_Create_Settings,
        PKB2_Email,
        PKB2_Email_Article,
        PKB2_Email_Invalid,
        PKB2_Error_Admin_Notification_Email,
        PKB2_Featured_Articles,
        PKB2_Feedback,
        PKB2_Feedback_Appreciated,
        PKB2_Feedback_Characters_Remaining,
        PKB2_First_Name,
        PKB2_Last_Name,
        PKB2_More_Useful,
        PKB2_Narrow_Search,
        PKB2_Next_Link,
        PKB2_No_Filter,
        PKB2_No_Found_Answer,
        PKB2_No_Results,
        PKB2_No_Settings_Yet,
        PKB2_None,
        PKB2_Popular_Articles,
        PKB2_Previous_Link,
        PKB2_Printable_View,
        PKB2_Recommended,
        PKB2_Related_Articles,
        PKB2_Request_Submitted,
        PKB2_Request_Type,
        PKB2_Reset_Search,
        PKB2_Search_Button,
        PKB2_Search_Prompt,
        PKB2_Search_Results,
        PKB2_Select_Settings,
        PKB2_Still_Have_Question,
        PKB2_Submit,
        PKB2_Subscribe_Article_Feed,
        PKB2_Subscribe_Feed_Results,
        PKB2_Thanks_For_Feedback,
        PKB2_Tweet_This,
        PKB2_Value_Must_Match_Name,
        PKB2_Was_Helpful,
        PKB2_Within_Category,
        PKB2_Yes_Submit_Question,
        PKB2_You_Searched_For,
        PositiveFeebgckNotificationMsf,
        QueryActiveUsers,
        reCAPTCHAbaseURL,
        reCAPTCHAChallengeLink,
        reCAPTCHANoScriptLink,
        reCAPTCHAprivateKey,
        reCAPTCHApublicKey,
        Save,
        SaveAndNew,
        Search,
        Select,
        Select1,
        SiteDomain,
        task_cancel,
        task_completed,
        task_informationReceived,
        task_inProgress,
        task_label_highPriority,
        task_open,
        task_outOfTime,
        task_pending,
        task_pendingFreakIt,
        task_saveEdit,
        task_task,
        TaskCreated,
        Tsk_Closed,
        unauthorized_message,
        unauthorized_title,
        Update_Rule,
        UpdatePhoneAndNewCase,
        uploadFile_attachments,
        uploadFile_upload,
        vfc06_AgentNotRecognized,
        VFC06_CaseLightCreated,
        VFC06_CaseLightNotCreated,
        VFC06_CreateCustomer,
        vfc06_NoAgents,
        vfc06_NoAgentsInputs,
        VFC06_TraceCaseLight,
        VFC07_DocumentName,
        VFC07_MissingDocumentEmailSubject,
        VFC07_MissingDocumentList,
        VFC07_NoDocuments,
        VFC07_NoSubCategory,
        VFC07_SendEmail,
        VFP01_2ndSupportType,
        VFP01_CreateTasks,
        VFP01_TaskCreation,
        VFP06_AAI_Agent,
        VFP06_AAIAgents,
        VFP06_AAICustomer,
        VFP06_AMFCustomer,
        VFP06_AMPSCustomer,
        VFP06_Bank_Agent,
        VFP06_CalledNumber,
        VFP06_CalledNumber_AAI,
        VFP06_CalledNumber_AMF,
        VFP06_CalledNumber_AMPS,
        VFP06_CalledNumber_Quadra,
        VFP06_CreateNewCase,
        VFP06_CustTypology,
        VFP06_Family_Protect,
        VFP06_InactiveAgent,
        VFP06_MissingAddress,
        VFP06_MissingContactMsg,
        VFP06_MissingEmail,
        VFP06_MissingPhone,
        VFP06_ModifyCustomer,
        VFP06_Multiple_Bank_Agents,
        VFP06_NoResultFound,
        VFP06_SearchedCaseNotFound,
        VFP06_ViewClaims,
        VFP08_BirthDate,
        VFP08_FillSearch,
        VFP08_LastName,
        VFP08_OverwriteEmail,
        VFP08_Successful,
        VFP11_Action_Performed,
        VFP11_Associated_Account,
        VFP11_Associated_Policies,
        VFP11_Link_Policy_to_Case,
        VFP11_Missing_Account,
        VFP11_No_Policies_Found,
        VFP12_Existing_rule,
        VFP12_Existing_rule_end,
        VFP12_No_Email_Selected,
        VFP12_Page_Sub_Title,
        VFP12_Page_Title,
        VFP12_Two_Emails_Not_allowed,
        VFP13_Attach_Article,
        VFP13_No_Article,
        VFP13_Table_Header,
        VFP14_Email_Address,
        VFP14_Email_Request_GDPR_Assistance,
        VFP14_Email_to_AAI_Agent,
        VFP14_Email_to_Agency,
        VFP14_Email_to_Agent,
        VFP14_Email_to_Blue_Ass,
        VFP14_Email_to_Customer,
        VFP14_Email_To_IPSI,
        VFP14_Email_to_My_Fox,
        VFP14_Email_to_Technical_Office,
        VFP14_IncomingEmail,
        VFP14_Next,
        VFP14_NoEmail,
        VFP14_Of,
        VFP14_Outbound_Email,
        VFP14_Page,
        VFP14_Previous,
        VFP14_SendAnEmail,
        VFP15_AutomaticTaskSection,
        VFP15_CaseTypologySection,
        VFP15_RuleAlreadyExists,
        VFP15_RuleHasBeenCreated,
        VFP15_RuleHasBeenUpdated,
        VFP15_RuleNotCreated,
        VFP15_RuleNotUpdated,
        VFP15_Sub_Title,
        VFP15_TechnicalOfficeNotAvailable,
        VFP15_Title,
        VFP15_UserSelectionSection,
        VFP15_UsersNotAvailable,
        VFP16_Button_not_available,
        VFP16_Missing_Inputs,
        VFP17_Content_Missing,
        VFP17_Message_Content,
        VFP17_Mobile_Selection,
        VFP17_No_Account,
        VFP17_No_Mobile,
        VFP17_Page_Label,
        VFP17_PageSubTitle,
        VFP17_PageTitle,
        VFP17_Send_SMS,
        VFP17_SMS_Not_Sent,
        VFP17_SMS_Sent,
        VFP17_Template_Selection,
        VFP19_InsertRequestSubject,
        VFP19_OutOfOfficeMsg,
        VFP19_SelectCategory,
        VFP19_SelectSubCategory,
        VFP19_StartChat,
        VFP19_SubTitle,
        VFP19_Title,
        VFP23_SearchAndSendTaskToAgent,
        VFP24_AssociateAgent,
        VFP24_SearchAndSendTaskToAgent,
        VFP25_SearchAndSendTaskToLead,
        VFP31_ShowClaims,
        ViewCase,
       	QuotationStatus,
        menu_Riforma_2024_Button,
        menu_Riforma_2024_href,
    };
}