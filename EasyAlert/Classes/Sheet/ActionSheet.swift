//
//  ActionSheet.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import Foundation

open class ActionSheet: Sheet {
    
    private let actionGroupView: ActionGroupView
    
    private var cancelActionGroupView: ActionGroupView?
    
    private let configuration: ActionAlertbleConfigurable
    
    public required init(
        customView: CustomizedView,
        configuration: ActionAlertbleConfigurable = ActionSheet.Configuration.globalConfiguration
    ) {
        self.configuration = configuration
        actionGroupView = ActionGroupView(customView: customView,
                                          actionLayout: self.configuration.actionLayout)
        super.init(customView: actionGroupView)
    }
    
//    open override func willLayoutContainer() {
//        super.willLayoutContainer()
//        actionGroupView.setCornerRadius(configuration.cornerRadius)
//    }
    
    // MARK: - Message and Title
    
    var titleConfiguration: TitleConfiguration?
    var messageConfiguration: MessageConfiguration?
}

extension ActionSheet: ActionAlertble {
    
    public func addAction(_ action: Action) {
        assert(isShowing == false)
        actionGroupView.actions.append(action)
        setViewForAction(action)
    }
    
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = configuration.actionViewType.init(style: action.style)
            action.view?.title = action.title
        }
    }
}
