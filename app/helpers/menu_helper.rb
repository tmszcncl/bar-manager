module MenuHelper

  def menu_item_new
    { action: 'new',
      link_name: 'New',
      link_path: root_path }
  end

  def menu_item_queued
    { action: 'queued',
      link_name: 'Queued',
      link_path: '/orders/queued',
      color: 'red',
      counter: Order.queued.count }
  end

  def menu_item_in_progress
    { action: 'in_progress',
      link_name: 'In Progress',
      link_path: '/orders/in_progress',
      color: 'orange',
      counter: Order.in_progress.count }
  end

  def menu_item_ready
    { action: 'ready',
      link_name: 'Ready',
      link_path: '/orders/ready',
      color: 'green',
      counter: Order.ready.count }
  end

  def menu_item_released
    { action: 'released',
      link_name: 'Released',
      link_path: released_orders_path }
  end
end