//
//  ViewController.swift
//  TableHeaderViewA11y
//
//  Created by Xu Yan on 9/13/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var greenRoomTableView: UIView { return greenRoomTableViewController.view }
    private lazy var backButton: UIButton = {
      let button = UIButton()
      button.setTitle("Back", for: .normal)
      button.setTitleColor(.black, for: .normal)
      button.backgroundColor = .white
      button.translatesAutoresizingMaskIntoConstraints = false
      button.accessibilityLabel = "Back"
      return button
    }()
    private let greenRoomTableViewController: MyGreenRoomTableViewController
    private let switchUserView: MySwitchUserView

    public init() {
      self.greenRoomTableViewController = MyGreenRoomTableViewController(style: .grouped)
      self.switchUserView = MySwitchUserView()
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
      super.viewDidLoad()

      addChild(greenRoomTableViewController)
      greenRoomTableViewController.didMove(toParent: self)
      greenRoomTableView.translatesAutoresizingMaskIntoConstraints = false
      switchUserView.translatesAutoresizingMaskIntoConstraints = false

      view.backgroundColor = .white
      view.addSubview(backButton)
      view.addSubview(greenRoomTableView)
      view.addSubview(switchUserView)

      NSLayoutConstraint.activate([
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

        greenRoomTableView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
        greenRoomTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        greenRoomTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        greenRoomTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

        switchUserView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        switchUserView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        switchUserView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      ])
    }
}

private final class MyGreenRoomTableViewController: UITableViewController {
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Table header view"
    label.textColor = .black
    label.numberOfLines = 0
    label.adjustsFontForContentSizeCategory = true
    label.isAccessibilityElement = true
    label.accessibilityLabel = "Table header view"
    label.accessibilityTraits.insert(.header)
    return label
  }()

  private var headerHeight: CGFloat = 0

  private var sections: [TableViewSectionController] = [] {
    didSet {
      assert(Thread.isMainThread)
      sections.forEach { $0.registerReusableViews(in: tableView) }
      tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    sections = [EmptySectionController()]
    // sections = []

    tableView.backgroundColor = .white
    tableView.sectionFooterHeight = 0.0
    tableView.estimatedRowHeight = UITableView.automaticDimension
    tableView.cellLayoutMarginsFollowReadableWidth = true
    tableView.tableHeaderView = titleLabel
    tableView.allowsSelection = false

    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
      titleLabel.widthAnchor.constraint(equalTo: tableView.widthAnchor),
      titleLabel.topAnchor.constraint(equalTo: tableView.topAnchor),
    ])
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let newHeaderHeight = titleLabel.bounds.height
    if !headerHeight.isEqual(to: newHeaderHeight) {
      // Set the header again to force the tableView to layout with the new height.
      headerHeight = newHeaderHeight
      DispatchQueue.main.async { [weak self] in
        self?.tableView.tableHeaderView = self?.titleLabel
      }
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard section <= sections.count else {
      assertionFailure("section index exceeds available sections")
      return 0
    }

    return sections[section].numberOfRows()
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
  {
     guard section <= sections.count else {
      assertionFailure("section index exceeds available sections")
      return nil
    }

    return sections[section].headerView(in: tableView)
  }

  // Provide a cell object for each row.
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    guard indexPath.section <= sections.count else {
      assertionFailure("section index exceeds available sections")
      return UITableViewCell()
    }

    return sections[indexPath.section].cellForRow(at: indexPath, in: tableView)
  }
}

private final class MySwitchUserView: UIView {
  private lazy var joiningAsLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Joining as ..."
    label.textColor = .black

    return label
  }()

  public init() {
    super.init(frame: .zero)
    addSubview(joiningAsLabel)
    NSLayoutConstraint.activate([
      joiningAsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      joiningAsLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      joiningAsLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      joiningAsLabel.widthAnchor.constraint(equalToConstant: joiningAsLabel.intrinsicContentSize.width),
      joiningAsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

/// Delegate and DataSource for a single UITableView section.
public protocol TableViewSectionController: class {
  /// Registers cell, header and footer classes with the tableView.
  func registerReusableViews(in tableView: UITableView)

  /// Number of rows displayed in this section.
  func numberOfRows() -> Int

  /// Returns the cell to be displayed at the provided indexPath.
  func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell

  /// Returns the header view to be displayed in this section or nil if no header should be
  /// displayed.
  func headerView(in tableView: UITableView) -> UITableViewHeaderFooterView?

  /// The height of the section header.
  func headerHeight() -> CGFloat

  /// Returns the footer view to be displayed in this section or nil if no footer should be
  /// displayed.
  func footerView(in tableView: UITableView) -> UITableViewHeaderFooterView?

  /// The height of the section footer.
  func footerHeight() -> CGFloat

  /// Tells the section controller that the row at the specified index was selected. Provides the
  /// cell that was selected, if it was visible.
  func didSelectRow(in tableView: UITableView, at indexPath: IndexPath, cell: UITableViewCell?)

  /// Asks the section controller if the specified row should be highlighted.
  ///
  /// - Parameter index: The index of the row
  /// - Returns: True if specified row should be highlighted. Default is `true`.
  func shouldHighlightRow(at index: Int) -> Bool

  /// Asks the section controller if editing menu should be shown for specified row.
  ///
  /// - Parameter index: The index of the row
  /// - Returns: True if editing menu should be shown for specified row. Default is `false`.
  func shouldShowMenuForRow(at index: Int) -> Bool

  /// Asks the section controller if can perform action for specified row.
  ///
  /// - Parameters:
  ///   - action: Action to be performed.
  ///   - index: The index of the row.
  /// - Returns: True if action can be performed for specified row. Default is `false`.
  func canPerformAction(_ action: Selector, forRowAt index: Int) -> Bool

  /// Tells the section controller that perform action is called for specified row.
  func performAction(_ action: Selector, forRowAt index: Int)

  /// Tells the section controller that a user tapped the detail button for the specified row.
  func accessoryButtonTapped(in tableView: UITableView, at indexPath: IndexPath)
}

extension TableViewSectionController {
  public func headerHeight() -> CGFloat { return 0.0 }
  public func headerView(in tableView: UITableView) -> UITableViewHeaderFooterView? { return nil }
  public func footerHeight() -> CGFloat { return 0.0 }
  public func footerView(in tableView: UITableView) -> UITableViewHeaderFooterView? { return nil }
  public func didSelectRow(
    in tableView: UITableView, at indexPath: IndexPath, cell: UITableViewCell?
  ) {}
  public func shouldHighlightRow(at index: Int) -> Bool { return true }
  public func shouldShowMenuForRow(at index: Int) -> Bool { return false }
  public func canPerformAction(_ action: Selector, forRowAt index: Int) -> Bool { return false }
  public func performAction(_ action: Selector, forRowAt index: Int) {}
  public func accessoryButtonTapped(in tableView: UITableView, at indexPath: IndexPath) {}
}

class EmptySectionController: TableViewSectionController {
  public init() {}

  func registerReusableViews(in tableView: UITableView) {
    tableView.register(
      EmptySectionCell.self,
      forCellReuseIdentifier: String(describing: EmptySectionCell.self))
    tableView.register(
      EmptySectionHeader.self,
      forHeaderFooterViewReuseIdentifier: String(describing: EmptySectionHeader.self)
    )
  }

  func numberOfRows() -> Int { 1 }

  func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
    let row = indexPath.row
    guard row >= 0, row < 1 else {
      assertionFailure()
      return UITableViewCell()
    }
    let cell =
        tableView.dequeueReusableCell(
          withIdentifier: String(describing: EmptySectionCell.self),
          for: indexPath
        ) as! EmptySectionCell
    return cell
  }

  func headerView(in tableView: UITableView) -> UITableViewHeaderFooterView? {
    guard
      let header = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: String(describing: EmptySectionHeader.self)) as? EmptySectionHeader
    else {
      assertionFailure()
      return nil
    }
    return header
  }

  func headerHeight() -> CGFloat { UITableView.automaticDimension }

  class EmptySectionCell: UITableViewCell {
    private lazy var cellLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.text = "Cell view"
      label.textColor = .black
      label.numberOfLines = 0
      label.adjustsFontForContentSizeCategory = true
      label.accessibilityLabel = "Cell view"
      return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: .default, reuseIdentifier: reuseIdentifier)
      backgroundColor = .white
      selectionStyle = .none
      contentView.addSubview(cellLabel)

      let constraints: [NSLayoutConstraint] = [
        cellLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
        cellLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
        cellLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        cellLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      ]
      NSLayoutConstraint.activate(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }

  class EmptySectionHeader: UITableViewHeaderFooterView {
    private lazy var sectionHeaderLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.text = "Section header view"
      label.textColor = .black
      label.numberOfLines = 0
      label.adjustsFontForContentSizeCategory = true
      label.accessibilityLabel = "Section header view"
      label.accessibilityTraits.insert(.header)
      return label
    }()

    public override init(reuseIdentifier: String?) {
      super.init(reuseIdentifier: reuseIdentifier)
      contentView.addSubview(sectionHeaderLabel)
      let constraints: [NSLayoutConstraint] = [
        sectionHeaderLabel.leadingAnchor.constraint(
          equalTo: contentView.layoutMarginsGuide.leadingAnchor),
        sectionHeaderLabel.trailingAnchor.constraint(
          equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        sectionHeaderLabel.topAnchor.constraint(
          equalTo: contentView.layoutMarginsGuide.topAnchor),
        sectionHeaderLabel.bottomAnchor.constraint(
          equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      ]

      NSLayoutConstraint.activate(constraints)
    }

    public required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}
