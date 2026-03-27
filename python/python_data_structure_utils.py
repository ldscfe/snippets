from typing import Any, List, Dict, Iterable

def deduplicate_list(lst: List[Any]) -> List[Any]:
    """
    去除列表中的重复元素，保留原有顺序。
    
    参数:
        lst (List[Any]): 输入列表。
    
    返回:
        List[Any]: 去重后的新列表。
    """
    seen = set()
    result = []
    for item in lst:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result

def sort_list(lst: List[Any], reverse: bool = False) -> List[Any]:
    """
    对列表进行排序。
    
    参数:
        lst (List[Any]): 输入列表。
        reverse (bool): 是否降序排序，默认为 False（升序）。

    返回:
        List[Any]: 排序后的列表。
    """
    return sorted(lst, reverse=reverse)

def flatten_list(nested: List[Any]) -> List[Any]:
    """
    将一层嵌套的列表拍平为一维列表。
    
    参数:
        nested (List[Any]): 嵌套列表。

    返回:
        List[Any]: 拍平后的列表。
    """
    result = []
    for item in nested:
        if isinstance(item, list):
            result.extend(item)
        else:
            result.append(item)
    return result

def merge_dicts(*dicts: Dict[Any, Any]) -> Dict[Any, Any]:
    """
    合并多个字典，后面的字典会覆盖前面的同名键。

    参数:
        *dicts (Dict[Any, Any]): 两个或多个字典。

    返回:
        Dict[Any, Any]: 合并后的字典。
    """
    result = {}
    for d in dicts:
        result.update(d)
    return result

def intersection_set(*sets: Iterable[Any]) -> set:
    """
    求多个集合的交集。

    参数:
        *sets (Iterable[Any]): 两个或多个集合。

    返回:
        set: 交集结果。
    """
    sets = [set(s) for s in sets]
    if not sets:
        return set()
    return set.intersection(*sets)

def union_set(*sets: Iterable[Any]) -> set:
    """
    求多个集合的并集。

    参数:
        *sets (Iterable[Any]): 两个或多个集合。

    返回:
        set: 并集结果。
    """
    sets = [set(s) for s in sets]
    if not sets:
        return set()
    return set.union(*sets)
